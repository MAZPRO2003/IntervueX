import io
from datetime import datetime
from typing import Dict, Any, List
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super(NumberedCanvas, self).__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_header_footer(num_pages)
            super(NumberedCanvas, self).showPage()
        super(NumberedCanvas, self).save()

    def draw_header_footer(self, page_count):
        self.saveState()
        # Suppress on cover page
        if self._pageNumber > 1:
            self.setFont("Helvetica", 8)
            self.setFillColor(colors.HexColor("#64748B"))
            # Header
            self.drawString(54, 750, "IntervueX — Personal AI Interview Preparation Coach")
            self.setStrokeColor(colors.HexColor("#E2E8F0"))
            self.setLineWidth(0.5)
            self.line(54, 744, 558, 744)

            # Footer
            self.line(54, 45, 558, 45)
            self.drawString(54, 32, "Confidential & Personalized Preparation Pack")
            page_str = f"Page {self._pageNumber} of {page_count}"
            self.drawRightString(558, 32, page_str)
        self.restoreState()

class PDFWorkbookGenerator:
    @staticmethod
    def generate_pack_pdf(
        job_data: Dict[str, Any],
        resume_data: Dict[str, Any],
        process_data: Dict[str, Any],
        questions: List[Dict[str, Any]],
        candidate_name: str = "Candidate"
    ) -> bytes:
        buffer = io.BytesIO()
        doc = SimpleDocTemplate(
            buffer,
            pagesize=letter,
            leftMargin=54,
            rightMargin=54,
            topMargin=54,
            bottomMargin=54
        )

        styles = getSampleStyleSheet()
        
        primary_color = colors.HexColor("#0F172A") # Deep Navy
        indigo_color = colors.HexColor("#4F46E5") # Electric Indigo
        text_dark = colors.HexColor("#1E293B")
        text_muted = colors.HexColor("#64748B")

        title_style = ParagraphStyle(
            'CoverTitle',
            parent=styles['Normal'],
            fontName='Helvetica-Bold',
            fontSize=28,
            leading=34,
            textColor=primary_color,
            spaceAfter=8
        )
        subtitle_style = ParagraphStyle(
            'CoverSubtitle',
            parent=styles['Normal'],
            fontName='Helvetica-Bold',
            fontSize=16,
            leading=22,
            textColor=indigo_color,
            spaceAfter=15
        )
        h1_style = ParagraphStyle(
            'H1Heading',
            parent=styles['Normal'],
            fontName='Helvetica-Bold',
            fontSize=18,
            leading=24,
            textColor=primary_color,
            spaceBefore=12,
            spaceAfter=8
        )
        h2_style = ParagraphStyle(
            'H2Heading',
            parent=styles['Normal'],
            fontName='Helvetica-Bold',
            fontSize=13,
            leading=18,
            textColor=indigo_color,
            spaceBefore=10,
            spaceAfter=6
        )
        body_style = ParagraphStyle(
            'Body',
            parent=styles['Normal'],
            fontName='Helvetica',
            fontSize=9.5,
            leading=14,
            textColor=text_dark
        )
        body_bold = ParagraphStyle(
            'BodyBold',
            parent=body_style,
            fontName='Helvetica-Bold'
        )
        quote_box_style = ParagraphStyle(
            'QuoteBox',
            parent=styles['Normal'],
            fontName='Helvetica-Oblique',
            fontSize=9,
            leading=13,
            textColor=colors.HexColor("#334155")
        )

        story = []

        # ================= COVER PAGE =================
        story.append(Spacer(1, 40))
        story.append(Paragraph("<b>IntervueX</b>", ParagraphStyle('Brand', fontName='Helvetica-Bold', fontSize=20, textColor=indigo_color)))
        story.append(Spacer(1, 40))
        story.append(Paragraph("AI Interview Preparation Pack", title_style))
        company_name = job_data.get("company", "Target Company")
        role_name = job_data.get("job_title", "Target Role")
        program_name = job_data.get("hiring_program", "Standard Recruitment Track")
        story.append(Paragraph(f"Comprehensive Roadmap & Question Workbook for {company_name}", subtitle_style))
        story.append(Spacer(1, 20))

        cover_meta = [
            [Paragraph("<b>Prepared For:</b>", body_bold), Paragraph(candidate_name, body_style)],
            [Paragraph("<b>Company:</b>", body_bold), Paragraph(company_name, body_style)],
            [Paragraph("<b>Target Role:</b>", body_bold), Paragraph(role_name, body_style)],
            [Paragraph("<b>Hiring Program:</b>", body_bold), Paragraph(program_name, body_style)],
            [Paragraph("<b>Experience Level:</b>", body_bold), Paragraph(job_data.get("experience_level", "Fresher"), body_style)],
            [Paragraph("<b>Date Generated:</b>", body_bold), Paragraph(datetime.now().strftime("%B %d, %Y"), body_style)],
            [Paragraph("<b>Questions Included:</b>", body_bold), Paragraph(f"{len(questions)} Curated & Evidence-Ranked Questions", body_style)],
        ]
        meta_table = Table(cover_meta, colWidths=[140, 340])
        meta_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F8FAFC")),
            ('PADDING', (0, 0), (-1, -1), 8),
            ('BOX', (0, 0), (-1, -1), 1, colors.HexColor("#E2E8F0")),
            ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ]))
        story.append(meta_table)

        story.append(Spacer(1, 40))
        disclaimer = Paragraph(
            "<i>Note: IntervueX aggregates verified job postings, reported candidate experiences, and tailored AI curriculum. "
            "Interview formats vary across hiring cycles. Focus on understanding core engineering concepts and structured communication.</i>",
            quote_box_style
        )
        story.append(disclaimer)
        story.append(PageBreak())

        # ================= SECTION 1: JOB & SKILL ANALYSIS =================
        story.append(Paragraph("1. Job & Skill Requirements", h1_style))
        story.append(HRFlowable(width="100%", thickness=1, color=indigo_color, spaceAfter=10))
        story.append(Paragraph(f"<b>Role Overview:</b> {job_data.get('summary', 'No summary provided')}", body_style))
        story.append(Spacer(1, 10))

        skills_obj = job_data.get("skills", {})
        req_skills = ", ".join(skills_obj.get("required_skills", [])) or "General Problem Solving"
        pref_skills = ", ".join(skills_obj.get("preferred_skills", [])) or "None specified"
        langs = ", ".join(skills_obj.get("programming_languages", [])) or "Any modern language"
        dbs = ", ".join(skills_obj.get("databases", [])) or "Relational DBs"

        skill_table_data = [
            [Paragraph("<b>Required Skills</b>", body_bold), Paragraph(req_skills, body_style)],
            [Paragraph("<b>Preferred Skills</b>", body_bold), Paragraph(pref_skills, body_style)],
            [Paragraph("<b>Languages</b>", body_bold), Paragraph(langs, body_style)],
            [Paragraph("<b>Databases & Storage</b>", body_bold), Paragraph(dbs, body_style)],
        ]
        skill_table = Table(skill_table_data, colWidths=[130, 350])
        skill_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (0, -1), colors.HexColor("#F1F5F9")),
            ('PADDING', (0, 0), (-1, -1), 6),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ]))
        story.append(skill_table)
        story.append(Spacer(1, 15))

        # ================= SECTION 2: INTERVIEW PROCESS & TIMELINE =================
        story.append(Paragraph("2. Reported Interview Process & Timeline", h1_style))
        story.append(HRFlowable(width="100%", thickness=1, color=indigo_color, spaceAfter=10))
        story.append(Paragraph(f"<b>Hiring Track:</b> {process_data.get('hiring_program', 'Standard')} (Confidence: {process_data.get('overall_confidence', 'Medium')})", body_bold))
        story.append(Paragraph(f"<i>{process_data.get('evidence_summary', '')}</i>", quote_box_style))
        story.append(Spacer(1, 8))

        rounds = process_data.get("rounds", [])
        for r in rounds:
            r_title = f"Round {r.get('round_number')}: {r.get('stage_name', 'Interview Round')}"
            story.append(Paragraph(r_title, h2_style))
            r_desc = f"<b>Format:</b> {r.get('assessment_format', 'N/A')}<br/><b>Purpose:</b> {r.get('purpose', '')}<br/><b>Key Topics:</b> {', '.join(r.get('expected_topics', []))}"
            story.append(Paragraph(r_desc, body_style))
            story.append(Spacer(1, 6))

        story.append(PageBreak())

        # ================= SECTION 3: CURATED QUESTION BANK =================
        story.append(Paragraph("3. Personalized Question Bank & Preparation Guide", h1_style))
        story.append(HRFlowable(width="100%", thickness=1, color=indigo_color, spaceAfter=10))
        story.append(Paragraph("Each question includes interviewer intent, expected answer structure, sample response, and critical follow-ups.", body_style))
        story.append(Spacer(1, 10))

        for idx, q in enumerate(questions, 1):
            q_flowables = []
            q_num_title = f"Q{idx}. [{q.get('category', 'Technical')}] ({q.get('difficulty', 'Medium')}) - {q.get('priority', 'High')} Priority"
            q_flowables.append(Paragraph(f"<b>{q_num_title}</b>", h2_style))
            q_flowables.append(Paragraph(f"<b>Question:</b> {q.get('question')}", body_bold))
            q_flowables.append(Spacer(1, 4))
            
            if q.get("frequency_evidence"):
                q_flowables.append(Paragraph(f"<i>Evidence: {q.get('frequency_evidence')} [{q.get('evidence_label', 'REPORTED')}]</i>", quote_box_style))
                q_flowables.append(Spacer(1, 4))

            hta = q.get("how_to_answer", {})
            if hta:
                hta_text = (
                    f"<b>Interviewer Intent:</b> {hta.get('interviewer_intent', 'Assess core reasoning')}<br/>"
                    f"<b>Natural Sample Answer (English):</b> {hta.get('natural_sample_answer_en', '')}<br/>"
                    f"<b>Concise Pitch:</b> {hta.get('short_answer_en', '')}"
                )
                q_flowables.append(Paragraph(hta_text, body_style))

            followups = q.get("follow_up_questions", [])
            if followups:
                q_flowables.append(Spacer(1, 4))
                f_text = "<b>Likely Follow-up Questions:</b><br/>" + "<br/>".join([f"• {f}" for f in followups[:3]])
                q_flowables.append(Paragraph(f_text, body_style))

            q_flowables.append(Spacer(1, 12))
            story.append(KeepTogether(q_flowables))

        # ================= SECTION 4: FINAL REVISION CHECKLIST =================
        story.append(PageBreak())
        story.append(Paragraph("4. Final 60-Minute Revision Checklist", h1_style))
        story.append(HRFlowable(width="100%", thickness=1, color=indigo_color, spaceAfter=10))
        checklist_items = [
            "Project Hook: Rehearse your 60-second architecture explanation out loud.",
            "SQL Drills: Write out subqueries and DENSE_RANK window functions on a blank sheet of paper.",
            "Resume Integrity: Review all technologies claimed on your resume and anticipate grilling points.",
            "Why This Company: Have 2 distinct facts prepared about their core business lines and technology culture.",
            "Behavioral: Have 2 concrete STAR-methodology stories ready (handling conflict, overcoming a technical failure).",
            "Questions for Interviewer: Prepare 2 insightful questions regarding their team's deployment architecture."
        ]
        for item in checklist_items:
            story.append(Paragraph(f"[  ] {item}", body_style))
            story.append(Spacer(1, 8))

        doc.build(story, canvasmaker=NumberedCanvas)
        return buffer.getvalue()
