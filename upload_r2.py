#!/usr/bin/env python3
"""
سكريبت رفع ملفات القرآن الصوتية إلى Cloudflare R2
يقوم بقراءة جميع مجلدات السور، رفع الملفات الصوتية، وإنشاء ملف data.json
"""

import os
import json
import mimetypes
from pathlib import Path
import boto3
from botocore.config import Config
from dotenv import load_dotenv

load_dotenv()

# إعدادات Cloudflare R2
R2_ENDPOINT = os.getenv("R2_ENDPOINT")
R2_ACCESS_KEY = os.getenv("R2_ACCESS_KEY")
R2_SECRET_KEY = os.getenv("R2_SECRET_KEY")
R2_BUCKET_NAME = os.getenv("R2_BUCKET_NAME", "fahemni-alquran")
R2_PUBLIC_URL = os.getenv("R2_PUBLIC_URL", "https://pub-xxxxx.r2.dev")

# مسار مجلد السور
SURAH_DIR = Path(__file__).parent / "السور"

# أنواع الملفات الصوتية المسموح بها
AUDIO_EXTENSIONS = {".mp3", ".aac", ".wav", ".ogg", ".m4a", ".wma"}

def init_r2_client():
    """تهيئة عميل R2"""
    if not all([R2_ENDPOINT, R2_ACCESS_KEY, R2_SECRET_KEY]):
        print("❌ خطأ: يرجى تعيين متغيرات البيئة التالية:")
        print("  R2_ENDPOINT")
        print("  R2_ACCESS_KEY")
        print("  R2_SECRET_KEY")
        print("  R2_BUCKET_NAME (اختياري)")
        print("  R2_PUBLIC_URL (اختياري)")
        exit(1)

    client = boto3.client(
        "s3",
        endpoint_url=R2_ENDPOINT,
        aws_access_key_id=R2_ACCESS_KEY,
        aws_secret_access_key=R2_SECRET_KEY,
        config=Config(signature_version="s3v4"),
    )
    return client


def ensure_bucket_exists(client):
    """التأكد من وجود الـ bucket"""
    try:
        client.head_bucket(Bucket=R2_BUCKET_NAME)
        print(f"✅ الـ bucket '{R2_BUCKET_NAME}' موجود مسبقاً")
    except Exception:
        print(f"📦 جاري إنشاء الـ bucket '{R2_BUCKET_NAME}'...")
        client.create_bucket(Bucket=R2_BUCKET_NAME)
        print(f"✅ تم إنشاء الـ bucket '{R2_BUCKET_NAME}'")


def upload_file(client, local_path, remote_path):
    """رفع ملف واحد إلى R2 مع الحفاظ على اسمه"""
    content_type, _ = mimetypes.guess_type(local_path)
    if content_type is None:
        if local_path.suffix == ".aac":
            content_type = "audio/aac"
        elif local_path.suffix == ".mp3":
            content_type = "audio/mpeg"
        else:
            content_type = "application/octet-stream"

    try:
        client.upload_file(
            str(local_path),
            R2_BUCKET_NAME,
            remote_path,
            ExtraArgs={
                "ContentType": content_type,
                "CacheControl": "public, max-age=31536000",
            },
        )
        print(f"  ✅ تم الرفع: {remote_path}")
        return True
    except Exception as e:
        print(f"  ❌ فشل رفع {remote_path}: {e}")
        return False


def scan_and_upload(client):
    """مسح مجلدات السور ورفع الملفات الصوتية"""
    if not SURAH_DIR.exists():
        print(f"❌ مجلد السور غير موجود: {SURAH_DIR}")
        return []

    surah_list = []
    total_uploaded = 0
    total_failed = 0

    # ترتيب المجلدات حسب الرقم
    folders = sorted(
        [f for f in SURAH_DIR.iterdir() if f.is_dir()],
        key=lambda x: x.name,
    )

    for folder in folders:
        surah_name = folder.name.strip()
        print(f"\n📖 سورة: {surah_name}")

        # جمع جميع الملفات الصوتية فقط
        audio_files = []
        for file in sorted(folder.iterdir()):
            if file.is_file() and file.suffix.lower() in AUDIO_EXTENSIONS:
                audio_files.append(file)

        if not audio_files:
            print(f"  ⚠️ لا توجد ملفات صوتية في هذه السورة")
            continue

        # رفع كل ملف صوتي
        uploaded_files = []
        for audio_file in audio_files:
            # الحفاظ على هيكل المجلدات: السور/اسم_السورة/اسم_الملف
            remote_path = f"audio/{surah_name}/{audio_file.name}"

            success = upload_file(client, audio_file, remote_path)
            if success:
                total_uploaded += 1
                file_url = f"{R2_PUBLIC_URL}/{remote_path}"
                uploaded_files.append({
                    "name": audio_file.stem,
                    "url": file_url,
                    "type": audio_file.suffix[1:],
                })
            else:
                total_failed += 1

        surah_list.append({
            "name": surah_name,
            "folder": surah_name,
            "files": uploaded_files,
            "count": len(uploaded_files),
        })

    print(f"\n{'='*50}")
    print(f"📊 الإحصائيات:")
    print(f"  📚 عدد السور: {len(surah_list)}")
    print(f"  ✅ تم الرفع: {total_uploaded}")
    print(f"  ❌ فشل: {total_failed}")
    print(f"{'='*50}")

    return surah_list


def generate_data_file(surah_list):
    """إنشاء ملف data.json"""
    data = {
        "app": "فهمني القرآن",
        "version": "1.0.0",
        "last_updated": __import__("datetime").datetime.now().isoformat(),
        "base_url": R2_PUBLIC_URL,
        "surahs": surah_list,
        "total_surahs": len(surah_list),
        "total_files": sum(s["count"] for s in surah_list),
    }

    data_path = Path(__file__).parent / "data.json"
    with open(data_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n✅ تم إنشاء ملف البيانات: {data_path}")
    print(f"   إجمالي السور: {data['total_surahs']}")
    print(f"   إجمالي الملفات الصوتية: {data['total_files']}")

    # نسخ data.json إلى مجلد Flutter assets
    flutter_assets = Path(__file__).parent / "fahemni_alquran" / "assets"
    if flutter_assets.exists():
        import shutil
        shutil.copy2(data_path, flutter_assets / "data.json")
        print(f"✅ تم نسخ data.json إلى assets المشروع")

    return data


def upload_data_file(client, data):
    """رفع ملف data.json إلى R2"""
    import io
    import json as json_mod

    json_str = json_mod.dumps(data, ensure_ascii=False, indent=2)
    json_bytes = json_str.encode("utf-8")

    try:
        client.put_object(
            Bucket=R2_BUCKET_NAME,
            Key="data.json",
            Body=json_bytes,
            ContentType="application/json; charset=utf-8",
            CacheControl="public, max-age=3600",
        )
        print(f"✅ تم رفع data.json إلى R2: {R2_PUBLIC_URL}/data.json")
    except Exception as e:
        print(f"❌ فشل رفع data.json إلى R2: {e}")


def main():
    print("=" * 50)
    print("  📖 سكريبت رفع ملفات فهمني القرآن")
    print("  إلى Cloudflare R2")
    print("=" * 50)

    client = init_r2_client()
    ensure_bucket_exists(client)
    surah_list = scan_and_upload(client)
    data = generate_data_file(surah_list)
    upload_data_file(client, data)

    print(f"\n🎉 تم الانتهاء بنجاح!")
    print(f"🌐 رابط البيانات: {R2_PUBLIC_URL}/data.json")


if __name__ == "__main__":
    main()
