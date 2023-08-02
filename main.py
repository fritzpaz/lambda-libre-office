import boto3
import subprocess
import os

os.makedirs("/tmp", exist_ok=True)

print(os.listdir('/tmp'))

OBJECT_KEY = os.getenv('OBJECT_KEY','s3_object_key')
INPUT_BUCKET_NAME = os.getenv('INPUT_BUCKET_NAME','input-bucket')
OUTPUT_BUCKET_NAME = os.getenv('OUTPUT_BUCKET_NAME','output-bucket')


os.environ['PATH'] = "/opt/libreoffice7.5/program:" + os.environ['PATH']

def convert_to_pdf(file):
    print("Starting conversion to PDF...")
    output_file = os.path.splitext(file)[0] + '.pdf'
    result = subprocess.run(['/opt/libreoffice7.5/program/soffice', '--headless', '--nologo', '--nodefault', '--nofirststartwizard', '--convert-to', 'pdf', file, '--outdir', '/tmp'], capture_output=True)
    if result.returncode != 0:
        print(f"LibreOffice conversion failed with return code: {result.returncode}")
        print(f"stderr: {result.stderr.decode()}")
        print(f"stdout: {result.stdout.decode()}")
        raise Exception("Conversion failed.")
    if not os.path.exists(output_file):
        print(os.listdir('/tmp')) 
        raise Exception(f"PDF file was not created. LibreOffice stdout: {result.stdout.decode()}, stderr: {result.stderr.decode()}")
    print("Conversion to PDF completed.")
    return output_file

def download_from_s3(bucket, key):
    print(f"Downloading {key} from S3...")
    s3 = boto3.client('s3')
    local_file = os.path.join("/tmp", os.path.basename(key))
    s3.download_file(bucket, key, local_file)
    if not os.path.exists(local_file):
        raise Exception("File was not downloaded")
    print(f"Downloaded {key} from S3.")
    return local_file

def upload_to_s3(bucket, key, file):
    print(f"Uploading {file} to S3...")
    if not os.path.exists(file):
        raise Exception("No such file to upload: " + file)
    s3 = boto3.client('s3')
    s3.upload_file(file, bucket, key)
    print(f"Uploaded {file} to S3.")

def handler(event, context):
    print("Starting main function...")
    os.environ["HOME"] = "/tmp"
    docx_file = download_from_s3(INPUT_BUCKET_NAME, OBJECT_KEY)
    pdf_file = convert_to_pdf(docx_file)
    upload_to_s3(OUTPUT_BUCKET_NAME, f"{OBJECT_KEY.split('/')[0]}/converted/{'/'.join(OBJECT_KEY.split('/')[1:])}.pdf", pdf_file)
    os.remove(docx_file)
    os.remove(pdf_file)
    print("Main function completed.")
    return {
        "statusCode": 200,
        "body": "Main function completed successfully"
    }

if __name__ == '__main__':
    handler(event=None, context=None)
