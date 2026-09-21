import io
import logging
from pypdf import PdfReader
import docx

logger = logging.getLogger(__name__)

class ResumeParser:
    @staticmethod
    def extract_from_pdf(pdf_bytes: bytes) -> str:
        try:
            reader = PdfReader(io.BytesIO(pdf_bytes))
            text = []
            for page in reader.pages:
                t = page.extract_text()
                if t:
                    text.append(t)
            return "\n".join(text)
        except Exception as e:
            logger.error(f"Error reading resume PDF: {e}")
            raise ValueError(f"Could not read PDF resume: {str(e)}")

    @staticmethod
    def extract_from_docx(docx_bytes: bytes) -> str:
        try:
            doc = docx.Document(io.BytesIO(docx_bytes))
            text = [p.text for p in doc.paragraphs if p.text]
            return "\n".join(text)
        except Exception as e:
            logger.error(f"Error reading resume DOCX: {e}")
            raise ValueError(f"Could not read DOCX resume: {str(e)}")
