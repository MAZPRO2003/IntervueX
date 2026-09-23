import io
import logging
from typing import Dict, Any, List
from pypdf import PdfReader
import docx

logger = logging.getLogger(__name__)

class ResumeParser:
    @staticmethod
    def extract_from_pdf(pdf_bytes: bytes) -> str:
        res = ResumeParser.extract_pdf_with_layout(pdf_bytes)
        return res["text"]

    @staticmethod
    def extract_pdf_with_layout(pdf_bytes: bytes) -> Dict[str, Any]:
        try:
            reader = PdfReader(io.BytesIO(pdf_bytes))
            pages_text = []
            full_text_lines = []
            page_lines = []

            for p_idx, page in enumerate(reader.pages):
                p_text = page.extract_text() or ""
                pages_text.append(p_text)
                lines = [l.strip() for l in p_text.splitlines() if l.strip()]
                total_p_lines = max(1, len(lines))

                for l_idx, line in enumerate(lines):
                    y_pct = round(10.0 + (l_idx / total_p_lines) * 80.0, 1)
                    full_text_lines.append(line)
                    page_lines.append({
                        "page": p_idx + 1,
                        "line": line,
                        "y_percent": y_pct
                    })

            full_text = "\n".join(full_text_lines).strip()
            if not full_text or len(full_text) < 15:
                raise ValueError("Extracted PDF text is empty or unreadable.")

            return {
                "text": full_text,
                "pages": pages_text,
                "page_lines": page_lines
            }
        except Exception as e:
            logger.error(f"Error reading resume PDF: {e}")
            raise ValueError(f"Could not read PDF resume: {str(e)}")

    @staticmethod
    def extract_from_docx(docx_bytes: bytes) -> str:
        try:
            doc = docx.Document(io.BytesIO(docx_bytes))
            text = [p.text.strip() for p in doc.paragraphs if p.text and p.text.strip()]
            full_text = "\n".join(text).strip()
            if not full_text or len(full_text) < 15:
                raise ValueError("Extracted DOCX text is empty or unreadable.")
            return full_text
        except Exception as e:
            logger.error(f"Error reading resume DOCX: {e}")
            raise ValueError(f"Could not read DOCX resume: {str(e)}")
