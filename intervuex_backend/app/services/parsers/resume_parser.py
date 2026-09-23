import io
import re
import logging
from typing import Dict, Any, List
from pypdf import PdfReader
import docx

logger = logging.getLogger(__name__)

class ResumeParser:
    @staticmethod
    def validate_resume_content(text: str) -> None:
        """
        Validates that extracted text represents an actual Resume or CV.
        Throws ValueError if document is non-resume text (e.g., general PDF, invoice, article, recipe, essay).
        """
        text_clean = (text or "").strip()
        if len(text_clean) < 60:
            raise ValueError("The uploaded document contains insufficient text (less than 60 characters). Please upload a complete resume.")

        lower_text = text_clean.lower()
        
        # 1. Contact Signals
        email_present = bool(re.search(r'[\w\.-]+@[\w\.-]+\.\w+', text_clean))
        phone_present = bool(re.search(r'\+?\d[\d\s-]{8,}\d', text_clean))
        link_present = any(domain in lower_text for domain in ["linkedin", "github", "gitlab", "portfolio", "http://", "https://", "www."])

        # 2. Standard Resume Section Headers / Keywords
        sections = [
            "education", "experience", "work history", "employment", "career",
            "skills", "technical skills", "projects", "key projects", "summary",
            "objective", "certifications", "academic", "university", "college",
            "degree", "bachelor", "master", "b.tech", "b.e", "b.s", "m.tech",
            "curriculum vitae", "resume", "c.v.", "gpa", "cgpa", "accomplishments",
            "responsibilities", "qualifications"
        ]
        matched_sections = [s for s in sections if s in lower_text]

        # 3. Technical / Professional Work Verbs & Role Titles
        roles_and_terms = [
            "developer", "engineer", "analyst", "intern", "consultant", "software",
            "python", "java", "c++", "javascript", "typescript", "sql", "react",
            "flutter", "html", "css", "git", "aws", "docker", "developed", "built",
            "designed", "engineered", "implemented", "managed", "created", "spearheaded"
        ]
        matched_terms = [t for t in roles_and_terms if t in lower_text]

        # Calculate Resume Indicator Score
        score = 0
        if email_present: score += 3
        if phone_present: score += 2
        if link_present: score += 2
        score += len(matched_sections) * 2
        score += min(6, len(matched_terms))

        if score < 4 and len(matched_sections) == 0:
            raise ValueError(
                "The uploaded document does not appear to be a valid Resume or CV. "
                "It lacks standard resume section headings (such as Education, Skills, Work Experience, or Projects). "
                "Please upload a professional resume."
            )

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
            ResumeParser.validate_resume_content(full_text)

            return {
                "text": full_text,
                "pages": pages_text,
                "page_lines": page_lines
            }
        except ValueError:
            raise
        except Exception as e:
            logger.error(f"Error reading resume PDF: {e}")
            raise ValueError(f"Could not read PDF resume: {str(e)}")

    @staticmethod
    def extract_from_docx(docx_bytes: bytes) -> str:
        try:
            doc = docx.Document(io.BytesIO(docx_bytes))
            text = [p.text.strip() for p in doc.paragraphs if p.text and p.text.strip()]
            full_text = "\n".join(text).strip()
            ResumeParser.validate_resume_content(full_text)
            return full_text
        except ValueError:
            raise
        except Exception as e:
            logger.error(f"Error reading resume DOCX: {e}")
            raise ValueError(f"Could not read DOCX resume: {str(e)}")

