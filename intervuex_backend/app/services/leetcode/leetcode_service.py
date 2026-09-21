import logging
import csv
import io
import urllib.request
import urllib.parse
from typing import List, Dict, Any, Optional
import asyncio
import httpx
from app.services.db.store import db_store

logger = logging.getLogger(__name__)

GITHUB_RAW_BASE = "https://raw.githubusercontent.com/liquidslr/leetcode-company-wise-problems/main"

# Exact casing matching directory names on liquidslr/leetcode-company-wise-problems repository
COMPANY_FOLDER_MAPPING = {
    "tata consultancy services": "tcs",
    "tcs": "tcs",
    "cognizant": "Cognizant",
    "cts": "Cognizant",
    "infosys": "Infosys",
    "wipro": "Wipro",
    "accenture": "Accenture",
    "deloitte": "Deloitte",
    "zoho": "Zoho",
    "razorpay": "razorpay",
    "hcltech": "HCL",
    "hcl": "HCL",
    "j.p. morgan": "J.P. Morgan",
    "jpmorgan": "J.P. Morgan",
    "jp morgan": "J.P. Morgan",
    "jpmorgan chase": "J.P. Morgan",
    "google": "Google",
    "amazon": "Amazon",
    "meta": "Meta",
    "facebook": "Meta",
    "microsoft": "Microsoft",
    "apple": "Apple",
    "netflix": "Netflix",
    "uber": "Uber",
    "adobe": "Adobe",
    "bloomberg": "Bloomberg",
    "goldman sachs": "Goldman Sachs",
    "oracle": "Oracle",
    "salesforce": "Salesforce",
    "walmart": "Walmart",
    "walmart labs": "Walmart Labs",
    "flipkart": "Flipkart",
    "atlassian": "Atlassian",
    "twitter": "X",
    "x": "X",
    "swiggy": "Swiggy",
    "zomato": "Zomato",
    "paytm": "Paytm",
    "phonepe": "PhonePe",
    "capgemini": "Capgemini",
    "tech mahindra": "Tech Mahindra",
    "techm": "Tech Mahindra",
    "ibm": "IBM",
    "cisco": "Cisco",
    "morgan stanley": "Morgan Stanley",
    "jio": "jio",
    "blinkit": "blinkit",
    "oyo": "oyo",
    "persistent systems": "persistent systems",
    "redbus": "redbus",
    "meesho": "Meesho",
    "myntra": "Myntra",
    "freshworks": "FreshWorks",
    "cred": "CRED",
    "ola": "Ola Cabs",
    "ola cabs": "Ola Cabs",
    "bytedance": "ByteDance",
    "tiktok": "TikTok",
    "nvidia": "Nvidia",
    "intel": "Intel",
    "samsung": "Samsung",
    "paypal": "PayPal",
    "stripe": "Stripe",
    "citadel": "Citadel",
    "jane street": "Jane Street",
    "two sigma": "Two Sigma",
    "de shaw": "DE Shaw",
}


class LeetCodeService:
    def __init__(self):
        self.cache: Dict[str, List[Dict[str, Any]]] = {}

    def _resolve_company_folder(self, company_name: str) -> str:
        clean = (company_name or "").strip().lower()
        if clean in COMPANY_FOLDER_MAPPING:
            return COMPANY_FOLDER_MAPPING[clean]
        for key, folder in COMPANY_FOLDER_MAPPING.items():
            if key in clean or clean in key:
                return folder
        # Default capitalization fallback
        return company_name.strip().title()

    async def fetch_leetcode_questions_async(self, company_name: str, pack_id: str) -> List[Dict[str, Any]]:
        cached = self.cache.get(pack_id)
        if cached is not None:
            return cached

        company_folder = self._resolve_company_folder(company_name)
        csv_files = [
            "1. 30 Days.csv",
            "1. Thirty Days.csv",
            "2. 3 Months.csv",
            "2. Three Months.csv",
            "3. 6 Months.csv",
            "3. Six Months.csv",
            "4. More Than 6 Months.csv",
            "4. More Than Six Months.csv",
            "5. All.csv",
            "5. All Time.csv"
        ]

        questions = []
        seen_urls = set()

        async def _fetch_csv(client: httpx.AsyncClient, csv_filename: str) -> Optional[str]:
            encoded_folder = urllib.parse.quote(company_folder)
            encoded_file = urllib.parse.quote(csv_filename)
            url = f"{GITHUB_RAW_BASE}/{encoded_folder}/{encoded_file}"
            try:
                resp = await client.get(url, timeout=4.0)
                if resp.status_code == 200 and resp.text:
                    return resp.text
            except Exception as e:
                logger.debug(f"Failed fetching {url}: {e}")
            return None

        try:
            async with httpx.AsyncClient(headers={'User-Agent': 'Mozilla/5.0'}, follow_redirects=True) as client:
                tasks = [_fetch_csv(client, f) for f in csv_files]
                results = await asyncio.gather(*tasks)

                for content in results:
                    if not content:
                        continue
                    reader = csv.DictReader(io.StringIO(content))
                    for row in reader:
                        link = row.get("Link", "").strip()
                        title = row.get("Title", "").strip()
                        if not title or not link or link in seen_urls:
                            continue
                        seen_urls.add(link)

                        topics_raw = row.get("Topics", "")
                        topics = [t.strip() for t in topics_raw.split(",") if t.strip()] if topics_raw else []

                        freq_str = row.get("Frequency", "0.0")
                        try:
                            freq = float(freq_str)
                        except ValueError:
                            freq = 0.0

                        questions.append({
                            "id": f"lc_{len(questions) + 1}",
                            "title": title,
                            "difficulty": row.get("Difficulty", "MEDIUM").strip().upper(),
                            "link": link,
                            "frequency": round(freq, 1),
                            "acceptance_rate": row.get("Acceptance Rate", "").strip(),
                            "topics": topics,
                            "company": company_name
                        })
        except Exception as e:
            logger.error(f"Error fetching LeetCode questions for {company_name}: {e}")

        # Sort questions by frequency descending if available
        questions.sort(key=lambda q: q.get("frequency", 0.0), reverse=True)

        # Fallback if no questions fetched from GitHub (e.g. offline or unlisted company)
        if not questions:
            questions = self._generate_default_leetcode_questions(company_name)

        self.cache[pack_id] = questions
        return questions

    def fetch_leetcode_questions(self, company_name: str, pack_id: str) -> List[Dict[str, Any]]:
        try:
            loop = asyncio.get_event_loop()
            if loop.is_running():
                return self._generate_default_leetcode_questions(company_name)
        except Exception:
            pass
        return asyncio.run(self.fetch_leetcode_questions_async(company_name, pack_id))

    def _generate_default_leetcode_questions(self, company_name: str) -> List[Dict[str, Any]]:
        return [
            {
                "id": f"lc_fallback_{company_name}_1",
                "title": f"Two Sum ({company_name} Focus)",
                "difficulty": "EASY",
                "link": "https://leetcode.com/problems/two-sum",
                "frequency": 98.5,
                "acceptance_rate": "52.4%",
                "topics": ["Array", "Hash Table"],
                "company": company_name
            },
            {
                "id": f"lc_fallback_{company_name}_2",
                "title": f"Add Two Numbers ({company_name} Focus)",
                "difficulty": "MEDIUM",
                "link": "https://leetcode.com/problems/add-two-numbers",
                "frequency": 85.0,
                "acceptance_rate": "43.1%",
                "topics": ["Linked List", "Math", "Recursion"],
                "company": company_name
            },
            {
                "id": f"lc_fallback_{company_name}_3",
                "title": "Longest Substring Without Repeating Characters",
                "difficulty": "MEDIUM",
                "link": "https://leetcode.com/problems/longest-substring-without-repeating-characters",
                "frequency": 82.3,
                "acceptance_rate": "34.9%",
                "topics": ["Hash Table", "String", "Sliding Window"],
                "company": company_name
            }
        ]

leetcode_service = LeetCodeService()

