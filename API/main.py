from fastapi import FastAPI, HTTPException, Depends, status, Header, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uuid
import os
import base64

app = FastAPI(title="نظام البلاغات المرورية", version="1.0.0")

# للسماح بالاتصال من التطبيق
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class UserSignup(BaseModel):
    first_name: str
    last_name: str
    phone: str
    password: str


class UserLogin(BaseModel):
    phone: str
    password: str


class ReportCreate(BaseModel):
    type: str
    car_number: str
    image_name: Optional[str] = None
    details: str


class ReportResponse(BaseModel):
    id: str
    type: str
    car_number: str
    image_name: Optional[str] = None
    details: str
    status: str
    date: datetime
    admin_response: Optional[str] = None


class ReportUpdate(BaseModel):
    status: str
    admin_response: Optional[str] = None


class PlateRecognitionResponse(BaseModel):
    success: bool
    car_number: Optional[str] = None
    error: Optional[str] = None


class PlateRecognitionBase64(BaseModel):
    image: str
    filename: str


# قاعدة بيانات مؤقتة
users_db = {}
reports_db = {}
tokens_db = {}

arabic = {
    "alif": "أ", "alef": "ا", "hamza": "ء", "hamza_on_alif": "أ",
    "hamza_under_alif": "إ", "hamza_on_waaw": "ؤ", "hamza_on_yaa": "ئ",
    "baa": "ب", "daal": "د", "dal": "د", "zal": "ذ", "zay": "ز",
    "aain": "ع", "ghain": "غ", "faa": "ف", "geem": "ج", "jeem": "ج",
    "haa": "ھ", "ha": "ح", "kaaf": "ك", "kaf": "ك", "laam": "ل",
    "meem": "م", "noon": "ن", "qaf": "ق", "raa": "ر", "ra": "ر",
    "sad": "ص", "dad": "ض", "seen": "س", "sheen": "ش", "taa": "ت",
    "taa_marbuta": "ة", "taa2": "ط", "waaw": "و", "yaa": "ي",
    "0": "٠", "1": "١", "2": "٢", "3": "٣", "4": "٤",
    "5": "٥", "6": "٦", "7": "٧", "8": "٨", "9": "٩"
}

# تحميل النموذج
from ultralytics import YOLO
MODEL_LOADED = True
model = YOLO("NTP_V1.pt")

def generate_token():
    return str(uuid.uuid4())


def verify_password(plain_password, hashed_password):
    return plain_password == hashed_password


def get_current_user(authorization: str = Header(None)):
    if not authorization:
        raise HTTPException(
            status_code=401,
            detail="مطلوب مصادقة"
        )

    try:
        # استخراج التوكن من الهيدر
        if authorization.startswith("Bearer "):
            token = authorization.replace("Bearer ", "").strip()
        else:
            token = authorization.strip()

        phone = tokens_db.get(token)
        if not phone:
            raise HTTPException(
                status_code=401,
                detail="توكن غير صالح"
            )

        user = users_db.get(phone)
        if user:
            return user
        else:
            raise HTTPException(
                status_code=401,
                detail="المستخدم غير موجود"
            )
    except Exception as e:
        raise HTTPException(
            status_code=401,
            detail=f"توكن غير صالح: {str(e)}"
        )


# دالة للتعرف على لوحة السيارة باستخدام base64
async def recognize_license_plate_base64(image_data: bytes) -> PlateRecognitionResponse:
    try:
        # حفظ الصورة مؤقتاً
        temp_image_path = f"temp_{uuid.uuid4().hex}.jpg"
        with open(temp_image_path, "wb") as f:
            f.write(image_data)

        try:
            results = model.predict(temp_image_path)

            items = []
            for box in results[0].boxes:
                class_id = int(box.cls[0])
                name = results[0].names[class_id]
                if name in arabic:
                    x1, y1, x2, y2 = box.xyxy[0]
                    center = (x1 + x2) / 2
                    items.append((center, arabic[name]))

            # ترتيب الأحرف بناءً على موقعها
            if items:
                items.sort(key=lambda x: x[0])

                # فصل كل حرف بمسافة
                characters = [ch for _, ch in items]
                text = " ".join(characters)

                print(f"✅ تم التعرف على النص: {text}")
            else:
                text = "لم يتم التعرف على أي نص"
                print("⚠️ لم يتم التعرف على أي نص في الصورة")

            return PlateRecognitionResponse(
                success=True,
                car_number=text
            )

        except Exception as e:
            print(f" خطأ في معالجة الصورة: {e}")
            return PlateRecognitionResponse(
                success=False,
                error=f"خطأ في معالجة الصورة: {str(e)}"
            )
        finally:
            # تنظيف الملف المؤقت
            if os.path.exists(temp_image_path):
                os.remove(temp_image_path)

    except Exception as e:
        print(f" خطأ في قراءة الصورة: {e}")
        return PlateRecognitionResponse(
            success=False,
            error=f"خطأ في قراءة الصورة: {str(e)}"
        )


# Endpoints
@app.post("/api/v2/signup", status_code=status.HTTP_201_CREATED)
async def signup(user_data: UserSignup):
    if user_data.phone in users_db:
        raise HTTPException(
            status_code=400,
            detail="رقم الهاتف مسجل مسبقاً"
        )

    # إنشاء المستخدم
    users_db[user_data.phone] = {
        "first_name": user_data.first_name,
        "last_name": user_data.last_name,
        "phone": user_data.phone,
        "password": user_data.password,
    }

    token = generate_token()
    tokens_db[token] = user_data.phone

    return {
        "message": "تم إنشاء الحساب بنجاح",
        "data": {
            "phone": user_data.phone,
            "token": token,
            "first_name": user_data.first_name,
            "last_name": user_data.last_name
        }
    }


@app.post("/api/v2/login")
async def login(login_data: UserLogin):
    user = users_db.get(login_data.phone)
    if not user or not verify_password(login_data.password, user["password"]):
        raise HTTPException(
            status_code=401,
            detail="رقم الهاتف أو كلمة المرور غير صحيحة"
        )

    token = generate_token()
    tokens_db[token] = login_data.phone

    return {
        "message": "تم تسجيل الدخول بنجاح",
        "data": {
            "phone": login_data.phone,
            "token": token,
            "first_name": user["first_name"],
            "last_name": user["last_name"]
        }
    }


@app.post("/api/v2/reports", response_model=ReportResponse)
async def create_report(report_data: ReportCreate, current_user: dict = Depends(get_current_user)):
    report_id = str(uuid.uuid4())
    report = {
        "id": report_id,
        "type": report_data.type,
        "car_number": report_data.car_number,
        "image_name": report_data.image_name,
        "details": report_data.details,
        "status": "قيد المراجعة",
        "date": datetime.now(),
        "admin_response": None,
        "user_phone": current_user["phone"]
    }

    reports_db[report_id] = report

    return report


@app.get("/api/v2/reports", response_model=List[ReportResponse])
async def get_user_reports(current_user: dict = Depends(get_current_user)):
    user_reports = [
        report for report in reports_db.values()
        if report["user_phone"] == current_user["phone"]
    ]
    return sorted(user_reports, key=lambda x: x["date"], reverse=True)


@app.put("/api/v2/reports/{report_id}")
async def update_report_status(report_id: str, update_data: ReportUpdate):
    if report_id not in reports_db:
        raise HTTPException(
            status_code=404,
            detail="البلاغ غير موجود"
        )

    reports_db[report_id]["status"] = update_data.status
    reports_db[report_id]["admin_response"] = update_data.admin_response

    return {
        "message": "تم تحديث حالة البلاغ",
        "data": reports_db[report_id]
    }


@app.get("/api/v2/user/profile")
async def get_user_profile(current_user: dict = Depends(get_current_user)):
    return {
        "message": "بيانات المستخدم",
        "data": current_user
    }


# endpoint للتحقق من صحة التوكن
@app.get("/api/v2/verify-token")
async def verify_token(current_user: dict = Depends(get_current_user)):
    return {
        "message": "التوكن صالح",
        "data": current_user
    }


# endpoint للتعرف على لوحة السيارة
@app.post("/api/v2/recognize-plate", response_model=PlateRecognitionResponse)
async def recognize_plate(file: UploadFile = File(...), current_user: dict = Depends(get_current_user)):
    # التحقق من نوع الملف
    if not file.content_type.startswith('image/'):
        raise HTTPException(
            status_code=400,
            detail="الملف يجب أن يكون صورة"
        )

    try:
        # قراءة بيانات الصورة
        image_data = await file.read()

        if len(image_data) == 0:
            raise HTTPException(
                status_code=400,
                detail="الصورة فارغة"
            )

        # التعرف على لوحة السيارة باستخدام النسخة الذكية
        result = await recognize_license_plate_base64(image_data)
        return result

    except Exception as e:
        return PlateRecognitionResponse(
            success=False,
            error=f"خطأ في معالجة الصورة: {str(e)}"
        )


# endpoint للتعرف على لوحة السيارة باستخدام base64
@app.post("/api/v2/recognize-plate-base64", response_model=PlateRecognitionResponse)
async def recognize_plate_base64(request: PlateRecognitionBase64, current_user: dict = Depends(get_current_user)):
    try:
        # فك تشفير base64
        image_data = base64.b64decode(request.image)

        # التعرف على لوحة السيارة باستخدام النسخة الذكية
        result = await recognize_license_plate_base64(image_data)
        return result

    except Exception as e:
        return PlateRecognitionResponse(
            success=False,
            error=f"خطأ في معالجة الصورة: {str(e)}"
        )


# Health check endpoint
@app.get("/")
async def root():
    return {"message": "نظام البلاغات المرورية يعمل بنجاح"}


@app.get("/health")
async def health_check():
    model_status = "loaded" if MODEL_LOADED else "not loaded"
    return {
        "status": "healthy",
        "timestamp": datetime.now(),
        "model_status": model_status,
        "total_users": len(users_db),
        "total_reports": len(reports_db)
    }


# endpoint to serve the admin page
@app.get("/admin", response_class=HTMLResponse)
async def admin_page():
    with open("admin.html", "r", encoding="utf-8") as f:
        return f.read()


# endpoint to get all reports (for admin)
@app.get("/api/v2/admin/reports", response_model=List[ReportResponse])
async def get_all_reports():
    all_reports = list(reports_db.values())
    return sorted(all_reports, key=lambda x: x["date"], reverse=True)


# Run the application correctly
if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
