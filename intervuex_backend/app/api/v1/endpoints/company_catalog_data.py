from typing import List, Dict, Any

EXPANDED_COMPANIES_CATALOG: List[Dict[str, Any]] = [
    # --- PREVIOUS TOP 38 COMPANIES ---
    {
        "id": "comp_tcs", "name": "Tata Consultancy Services", "short_name": "TCS", "category": "IT Services & Consulting", "color_hex": "#0F4C81",
        "hiring_programs": [
            {"id": "tcs_ninja", "name": "NQT — Ninja Track", "role": "Systems Engineer", "package_lpa": "3.36 - 3.6 LPA", "difficulty": "Easy to Medium", "rounds_count": 2, "overview": "Focuses on foundational aptitude, core programming logic, basic SQL, and HR fit.", "typical_rounds": ["National Qualifier Foundation", "Combined Technical & HR Panel"]},
            {"id": "tcs_digital", "name": "NQT — Digital Track", "role": "Digital Software Engineer", "package_lpa": "7.0 - 7.5 LPA", "difficulty": "Medium to Hard", "rounds_count": 3, "overview": "Requires strong DSA, web/cloud concepts, microservices, and database indexing.", "typical_rounds": ["Advanced NQT Assessment", "In-Depth Technical Panel", "Managerial & HR Interview"]},
            {"id": "tcs_prime", "name": "NQT — Prime Track", "role": "Prime Systems Architect / R&D", "package_lpa": "9.0 - 11.5 LPA", "difficulty": "Hard", "rounds_count": 3, "overview": "Highest campus tier testing complex graph/tree algorithms, low-level architecture, and AI/ML.", "typical_rounds": ["Prime Coding Challenge", "System Architecture & DSA Bar Raiser", "Executive Leadership Interview"]}
        ]
    },
    {
        "id": "comp_amazon", "name": "Amazon", "short_name": "Amazon", "category": "Product MNC", "color_hex": "#FF9900",
        "hiring_programs": [
            {"id": "amazon_sde1", "name": "SDE I (Software Development Engineer)", "role": "Software Development Engineer I", "package_lpa": "28 - 45 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "LeetCode Medium/Hard DSA and Amazon's 16 Leadership Principles in STAR format.", "typical_rounds": ["Online Assessment", "Technical Round 1: DSA", "Technical Round 2: OOD", "Bar Raiser & Leadership"]},
            {"id": "amazon_sde2", "name": "SDE II", "role": "Software Development Engineer II", "package_lpa": "55 - 80 LPA", "difficulty": "Very Hard", "rounds_count": 5, "overview": "High-scale Distributed Systems Design (HLD/LLD), microservices, caching, concurrency.", "typical_rounds": ["Online Coding & System Assessment", "Low-Level Design (LLD)", "High-Level System Design (HLD)", "DSA Optimization", "Bar Raiser"]}
        ]
    },
    {
        "id": "comp_google", "name": "Google", "short_name": "Google", "category": "Product MNC", "color_hex": "#4285F4",
        "hiring_programs": [
            {"id": "google_swe", "name": "Software Engineer (L3 / Campus)", "role": "Software Engineer", "package_lpa": "35 - 55 LPA", "difficulty": "Very Hard", "rounds_count": 5, "overview": "World-class algorithmic problem solving, clean maintainable code on Google Docs, and Googlyness.", "typical_rounds": ["Google Online Challenge", "Technical Round 1: Data Structures", "Technical Round 2: DP & Graphs", "Technical Round 3: Optimization", "Googleyness & Leadership"]}
        ]
    },
    {
        "id": "comp_microsoft", "name": "Microsoft", "short_name": "Microsoft", "category": "Product MNC", "color_hex": "#00A4EF",
        "hiring_programs": [
            {"id": "ms_sde", "name": "Software Engineer (New Grad / SDE)", "role": "Software Engineer", "package_lpa": "25 - 45 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "Tree/graph algorithms, bit manipulation, OOP architecture, and Growth Mindset.", "typical_rounds": ["Codility Assessment", "Technical Round 1: DSA", "Technical Round 2: OOD & Patterns", "Partner Engineering Round"]}
        ]
    },
    {
        "id": "comp_infosys", "name": "Infosys", "short_name": "Infosys", "category": "IT Services & Consulting", "color_hex": "#007CC3",
        "hiring_programs": [
            {"id": "infy_se", "name": "Systems Engineer", "role": "Systems Engineer", "package_lpa": "3.6 LPA", "difficulty": "Easy to Medium", "rounds_count": 2, "overview": "Aptitude, reasoning, pseudocode debugging, and fundamental technical panel interview.", "typical_rounds": ["Online Test", "Technical + HR Interview"]},
            {"id": "infy_sp", "name": "Specialist Programmer (Power Programmer)", "role": "Specialist Programmer", "package_lpa": "8.0 - 9.5 LPA", "difficulty": "Hard", "rounds_count": 2, "overview": "HackWithInfy qualifier, competitive programming questions on DP, greedy, and trees.", "typical_rounds": ["HackWithInfy Coding Qualifier", "Technical Panel on Advanced Algorithms"]}
        ]
    },
    {
        "id": "comp_cognizant", "name": "Cognizant", "short_name": "CTS", "category": "IT Services & Consulting", "color_hex": "#1F4388",
        "hiring_programs": [
            {"id": "cts_genc", "name": "GenC / GenC Elevate", "role": "Programmer Analyst Trainee", "package_lpa": "4.0 - 5.5 LPA", "difficulty": "Easy to Medium", "rounds_count": 2, "overview": "General aptitude, hands-on coding, SQL queries, OOP principles, and project deep dive.", "typical_rounds": ["Skill Assessment", "Technical & HR Panel"]},
            {"id": "cts_next", "name": "GenC Next", "role": "Software Development Engineer", "package_lpa": "6.75 - 9.0 LPA", "difficulty": "Hard", "rounds_count": 3, "overview": "Advanced programming, data structures, cloud fundamentals, and system troubleshooting.", "typical_rounds": ["Advanced Coding Test", "DSA Round", "Architecture & Defense"]}
        ]
    },
    {
        "id": "comp_zoho", "name": "Zoho Corporation", "short_name": "Zoho", "category": "Product MNC / SaaS", "color_hex": "#E42528",
        "hiring_programs": [
            {"id": "zoho_dev", "name": "Software Developer", "role": "Software Developer", "package_lpa": "6.0 - 10.0 LPA", "difficulty": "Medium to Hard", "rounds_count": 4, "overview": "Rigorous on-paper coding without IDEs, matrix/string manipulation, and 3-hour CLI Application Development.", "typical_rounds": ["Round 1: Basic Programming", "Round 2: Advanced Coding (No IDE)", "Round 3: CLI Application Build (Railway/Taxi)", "Round 4: Technical & HR Alignment"]}
        ]
    },
    {
        "id": "comp_wipro", "name": "Wipro", "short_name": "Wipro", "category": "IT Services & Consulting", "color_hex": "#5E2750",
        "hiring_programs": [
            {"id": "wipro_elite", "name": "Elite National Talent Hunt", "role": "Project Engineer", "package_lpa": "3.5 - 6.5 LPA", "difficulty": "Easy to Medium", "rounds_count": 2, "overview": "NLTH Online Test (Aptitude, Written English, Coding) and technical panel.", "typical_rounds": ["NLTH Online Test", "Technical + HR Panel"]}
        ]
    },
    {
        "id": "comp_accenture", "name": "Accenture", "short_name": "Accenture", "category": "IT Services & Consulting", "color_hex": "#A100FF",
        "hiring_programs": [
            {"id": "acc_ase", "name": "Associate Software Engineer (ASE / Advanced)", "role": "Associate Software Engineer", "package_lpa": "4.5 - 6.5 LPA", "difficulty": "Easy to Medium", "rounds_count": 3, "overview": "Cognitive & technical assessments, pseudocode analysis, coding, and communication test.", "typical_rounds": ["Cognitive & Technical Test", "Coding Assessment", "Communication & HR"]}
        ]
    },
    {
        "id": "comp_deloitte", "name": "Deloitte", "short_name": "Deloitte", "category": "Consulting & Technology", "color_hex": "#86BC25",
        "hiring_programs": [
            {"id": "deloitte_analyst", "name": "Associate Analyst / Technology", "role": "Associate Analyst", "package_lpa": "4.5 - 7.6 LPA", "difficulty": "Medium", "rounds_count": 3, "overview": "Analytical problem solving, Versant communication, business case study, and SQL.", "typical_rounds": ["Aptitude & Versant Test", "Case Study & Technical Round", "Partner Interview"]}
        ]
    },
    {
        "id": "comp_meta", "name": "Meta", "short_name": "Meta", "category": "Product MNC", "color_hex": "#0668E1",
        "hiring_programs": [
            {"id": "meta_e3", "name": "Software Engineer (E3 / New Grad)", "role": "Software Engineer", "package_lpa": "35 - 55 LPA", "difficulty": "Very Hard", "rounds_count": 4, "overview": "Rapid algorithmic problem solving (2 medium/hard questions in 45 mins) and graph traversals.", "typical_rounds": ["Online Screening", "Coding Round 1 (Speed & Precision)", "Coding Round 2 (Algorithms)", "Behavioral & Meta Values"]}
        ]
    },
    {
        "id": "comp_apple", "name": "Apple", "short_name": "Apple", "category": "Product MNC", "color_hex": "#A2AAAD",
        "hiring_programs": [
            {"id": "apple_swe", "name": "Software Engineer (ICT3 / Campus)", "role": "Software Engineer", "package_lpa": "30 - 50 LPA", "difficulty": "Hard to Very Hard", "rounds_count": 5, "overview": "Systems programming, memory management, C++/Swift internals, and low-level architecture.", "typical_rounds": ["Recruiter Tech Screen", "Technical Phone Screen", "Onsite 1: Algorithms & Memory", "Onsite 2: System Architecture", "Engineering Manager"]}
        ]
    },
    {
        "id": "comp_netflix", "name": "Netflix", "short_name": "Netflix", "category": "Product MNC", "color_hex": "#E50914",
        "hiring_programs": [
            {"id": "netflix_swe", "name": "Senior Software Engineer", "role": "Software Engineer", "package_lpa": "60 - 120 LPA", "difficulty": "Very Hard", "rounds_count": 5, "overview": "Ultra high-scale distributed architecture, microservices, concurrency, and Netflix Culture Memo.", "typical_rounds": ["Tech Recruiter Screen", "System Design & Microservices", "Concurrency & Resiliency", "Culture Round 1: Context Not Control", "Executive Director"]}
        ]
    },
    {
        "id": "comp_uber", "name": "Uber", "short_name": "Uber", "category": "Product MNC", "color_hex": "#000000",
        "hiring_programs": [
            {"id": "uber_sde1", "name": "Software Engineer I", "role": "Software Engineer", "package_lpa": "30 - 48 LPA", "difficulty": "Hard to Very Hard", "rounds_count": 4, "overview": "Geospatial indexing (H3), graph shortest paths, concurrent algorithms, and low-level system design.", "typical_rounds": ["Uber Online Challenge", "Technical Round 1: Graph/Tree Algorithms", "Technical Round 2: LLD", "Managerial & Culture"]}
        ]
    },
    {
        "id": "comp_adobe", "name": "Adobe", "short_name": "Adobe", "category": "Product MNC", "color_hex": "#FF0000",
        "hiring_programs": [
            {"id": "adobe_mts", "name": "Member of Technical Staff 1 (MTS-1)", "role": "Member of Technical Staff", "package_lpa": "22 - 35 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "C++/Java core fundamentals, graphics/tree algorithms, memory optimization, and OOP design.", "typical_rounds": ["Adobe HackerRank Test", "Technical 1: Data Structures & Pointers", "Technical 2: OS & Algorithms", "Director Interview"]}
        ]
    },
    {
        "id": "comp_salesforce", "name": "Salesforce", "short_name": "Salesforce", "category": "Product MNC / SaaS", "color_hex": "#00A1E0",
        "hiring_programs": [
            {"id": "sf_amts", "name": "Associate Member of Technical Staff (AMTS)", "role": "Associate Software Engineer", "package_lpa": "25 - 40 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "Multi-tenant cloud architecture, distributed systems, clean modular coding, and OOP.", "typical_rounds": ["HackerRank Assessment", "Technical 1: DSA", "Technical 2: OOD & DB Schema", "Values & Behavioral"]}
        ]
    },
    {
        "id": "comp_oracle", "name": "Oracle", "short_name": "Oracle", "category": "Product MNC / Enterprise", "color_hex": "#C74634",
        "hiring_programs": [
            {"id": "oracle_se", "name": "Software Developer (Server Tech / OCI)", "role": "Software Developer", "package_lpa": "18 - 32 LPA", "difficulty": "Medium to Hard", "rounds_count": 4, "overview": "Database engine internals, B+ trees, SQL optimizations, networking protocols, OS concurrency.", "typical_rounds": ["Oracle OA", "Technical 1: OS, DB Internals & Pointers", "Technical 2: DSA & Systems", "Managerial Interview"]}
        ]
    },
    {
        "id": "comp_cisco", "name": "Cisco", "short_name": "Cisco", "category": "Networking & Cloud", "color_hex": "#1BA0D7",
        "hiring_programs": [
            {"id": "cisco_se", "name": "Software Engineer (Technical Graduate)", "role": "Software Engineer", "package_lpa": "15 - 24 LPA", "difficulty": "Medium to Hard", "rounds_count": 3, "overview": "Networking (TCP/IP, Sockets, BGP), OS, C/C++ memory mechanics, and DSA.", "typical_rounds": ["Cisco OA", "Technical: Networking & Socket Programming", "HR Panel"]}
        ]
    },
    {
        "id": "comp_atlassian", "name": "Atlassian", "short_name": "Atlassian", "category": "Product MNC / SaaS", "color_hex": "#0052CC",
        "hiring_programs": [
            {"id": "atl_swe", "name": "Software Engineer (Graduate)", "role": "Software Engineer", "package_lpa": "35 - 55 LPA", "difficulty": "Hard to Very Hard", "rounds_count": 4, "overview": "Code craft, system design, data structures, and Atlassian's 5 Core Values.", "typical_rounds": ["HackerRank Challenge", "Code Craft / Pair Programming", "System Design & LLD", "Values & Behavioral"]}
        ]
    },
    {
        "id": "comp_goldman", "name": "Goldman Sachs", "short_name": "Goldman", "category": "Fintech & Investment Banking", "color_hex": "#7399C6",
        "hiring_programs": [
            {"id": "gs_analyst", "name": "Engineering New Analyst", "role": "Software Engineering Analyst", "package_lpa": "24 - 38 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "Mathematical probability, dynamic programming, matrix operations, and financial computing.", "typical_rounds": ["GS Online Assessment (Quant + Coding)", "Technical 1: Algorithms", "Technical 2: Systems & Math", "Engineering Director Panel"]}
        ]
    },
    {
        "id": "comp_jpmorgan", "name": "JPMorgan Chase", "short_name": "JPMC", "category": "Fintech & Investment Banking", "color_hex": "#1175B5",
        "hiring_programs": [
            {"id": "jpmc_sep", "name": "Software Engineer Program (SEP)", "role": "Software Engineer", "package_lpa": "16 - 22 LPA", "difficulty": "Medium to Hard", "rounds_count": 3, "overview": "HackerRank CodeVue challenge, Code for Good hackathon evaluation, Java/Spring & SQL.", "typical_rounds": ["Online Assessment", "Code for Good Hackathon / Tech Evaluation", "Technical & HR Panel"]}
        ]
    },
    {
        "id": "comp_flipkart", "name": "Flipkart", "short_name": "Flipkart", "category": "Product MNC / E-Commerce", "color_hex": "#2874F0",
        "hiring_programs": [
            {"id": "fk_sde1", "name": "SDE I", "role": "Software Development Engineer I", "package_lpa": "22 - 32 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "Machine Coding round (2 hours live object-oriented CLI app build), DSA, and high-scale e-commerce.", "typical_rounds": ["Online Qualifier", "Machine Coding Round (2 Hours LLD)", "DSA & Problem Solving", "Managerial & Culture"]}
        ]
    },
    {
        "id": "comp_swiggy", "name": "Swiggy", "short_name": "Swiggy", "category": "Product / Consumer Tech", "color_hex": "#FC8019",
        "hiring_programs": [
            {"id": "swiggy_sde1", "name": "SDE I", "role": "Software Engineer", "package_lpa": "20 - 30 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "Machine coding round (Food delivery LLD), LeetCode Medium/Hard DSA, and concurrency.", "typical_rounds": ["Online Qualifier", "Machine Coding (2 Hours LLD)", "DSA Optimization", "Culture Fit"]}
        ]
    },
    {
        "id": "comp_zomato", "name": "Zomato", "short_name": "Zomato", "category": "Product / Consumer Tech", "color_hex": "#CB202D",
        "hiring_programs": [
            {"id": "zomato_se", "name": "Software Development Engineer", "role": "Software Engineer", "package_lpa": "20 - 32 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "Fast execution, clean code architecture, machine coding, database indexing, and system scaling.", "typical_rounds": ["Online Assessment", "Machine Coding / LLD", "Problem Solving & DSA", "Engineering Manager"]}
        ]
    },
    {
        "id": "comp_paytm", "name": "Paytm", "short_name": "Paytm", "category": "Fintech / Consumer Tech", "color_hex": "#002E6D",
        "hiring_programs": [
            {"id": "paytm_se", "name": "Software Engineer", "role": "Software Engineer", "package_lpa": "12 - 20 LPA", "difficulty": "Medium to Hard", "rounds_count": 3, "overview": "High throughput payment transaction architecture, database transactions (ACID), SQL, and DSA.", "typical_rounds": ["Online Assessment", "Technical 1: DSA & Concurrency", "Technical 2: System Concepts & DB Transactions"]}
        ]
    },
    {
        "id": "comp_phonepe", "name": "PhonePe", "short_name": "PhonePe", "category": "Fintech / Consumer Tech", "color_hex": "#5F259F",
        "hiring_programs": [
            {"id": "phonepe_sde1", "name": "Software Engineer I", "role": "Software Engineer", "package_lpa": "22 - 35 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "Machine coding round (Payment Gateway / Ledger LLD), transactional consistency, distributed queues.", "typical_rounds": ["Online Qualifier", "Machine Coding / LLD (2 Hours)", "DSA & Algorithms", "Engineering Director"]}
        ]
    },
    {
        "id": "comp_razorpay", "name": "Razorpay", "short_name": "Razorpay", "category": "Fintech / B2B SaaS", "color_hex": "#0C2340",
        "hiring_programs": [
            {"id": "razorpay_sde1", "name": "Software Engineer I", "role": "Software Engineer", "package_lpa": "20 - 32 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "Machine coding, financial API design, web security (OAuth, HMAC, webhooks), and DSA.", "typical_rounds": ["Online Screening", "Machine Coding (LLD)", "Problem Solving & Systems", "Culture & Leadership"]}
        ]
    },
    {
        "id": "comp_capgemini", "name": "Capgemini", "short_name": "Capgemini", "category": "IT Services & Consulting", "color_hex": "#0070AD",
        "hiring_programs": [
            {"id": "capg_analyst", "name": "Analyst / Senior Analyst", "role": "Software Engineer Analyst", "package_lpa": "4.0 - 7.5 LPA", "difficulty": "Easy to Medium", "rounds_count": 3, "overview": "Pseudo-code, game-based aptitude test, hands-on coding, and technical interview.", "typical_rounds": ["Game-based Test & Pseudocode", "Coding Assessment", "Technical & HR Panel"]}
        ]
    },
    {
        "id": "comp_techm", "name": "Tech Mahindra", "short_name": "TechM", "category": "IT Services & Consulting", "color_hex": "#E31837",
        "hiring_programs": [
            {"id": "techm_se", "name": "Associate Software Engineer", "role": "Associate Software Engineer", "package_lpa": "3.5 - 5.5 LPA", "difficulty": "Easy to Medium", "rounds_count": 3, "overview": "Aptitude, psychometric test, basic coding, and technical panel interview.", "typical_rounds": ["Aptitude & English Test", "Hands-on Coding", "Technical & HR Panel"]}
        ]
    },
    {
        "id": "comp_hcltech", "name": "HCLTech", "short_name": "HCL", "category": "IT Services & Consulting", "color_hex": "#00569B",
        "hiring_programs": [
            {"id": "hcl_engineer", "name": "Software Engineer", "role": "Software Engineer", "package_lpa": "3.6 - 6.0 LPA", "difficulty": "Easy to Medium", "rounds_count": 2, "overview": "Aptitude screening, basic programming in C/Java/Python, SQL, and panel discussion.", "typical_rounds": ["Online Aptitude & MCQ", "Technical & HR Panel"]}
        ]
    },
    {
        "id": "comp_ibm", "name": "IBM", "short_name": "IBM", "category": "IT Services & Consulting", "color_hex": "#052147",
        "hiring_programs": [
            {"id": "ibm_se", "name": "Associate System Engineer", "role": "Associate System Engineer", "package_lpa": "4.5 - 7.2 LPA", "difficulty": "Medium", "rounds_count": 3, "overview": "Cognitive Ability Assessment (Cognify game test), English proficiency, coding, and panel.", "typical_rounds": ["IBM Cognify Game Assessment", "Coding Test", "Technical & HR Interview"]}
        ]
    },
    {
        "id": "comp_cred", "name": "CRED", "short_name": "CRED", "category": "Fintech / Product Unicorn", "color_hex": "#1A1A1A",
        "hiring_programs": [
            {"id": "cred_backend", "name": "Backend Engineer (SDE I / SDE II)", "role": "Software Development Engineer", "package_lpa": "24 - 45 LPA", "difficulty": "Hard to Very Hard", "rounds_count": 4, "overview": "Machine Coding (2 Hours LLD for rewards/payments), microservices, distributed caching, and bar raiser.", "typical_rounds": ["Online Assessment", "Machine Coding (2 Hours LLD)", "High-Level Distributed System Design", "Bar Raiser"]}
        ]
    },
    {
        "id": "comp_jio", "name": "Reliance Jio", "short_name": "Jio", "category": "Telecom & Digital Ecosystem", "color_hex": "#0F52BA",
        "hiring_programs": [
            {"id": "jio_se", "name": "Graduate Engineer Trainee (GET) / SDE", "role": "Software Engineer", "package_lpa": "6.0 - 14.0 LPA", "difficulty": "Medium to Hard", "rounds_count": 3, "overview": "Cloud platforms (JioCloud), microservices, database scaling, networking, and 5G applications.", "typical_rounds": ["Jio CodeBytes Test", "Technical 1: DSA & Core CS", "Technical 2: Cloud Systems & Projects", "HR Interview"]}
        ]
    },
    {
        "id": "comp_ltimindtree", "name": "LTIMindtree", "short_name": "LTIMindtree", "category": "IT Services & Digital Solutions", "color_hex": "#00205B",
        "hiring_programs": [
            {"id": "lti_se", "name": "Software Engineer / Specialist", "role": "Software Engineer", "package_lpa": "4.5 - 8.5 LPA", "difficulty": "Easy to Medium", "rounds_count": 3, "overview": "National Qualifier assessment, core OOP, SQL subqueries, cloud basics, and project defense.", "typical_rounds": ["LTIMindtree National Qualifier", "Technical Panel", "Managerial & HR Alignment"]}
        ]
    },
    {
        "id": "comp_freshworks", "name": "Freshworks", "short_name": "Freshworks", "category": "Product MNC / B2B SaaS", "color_hex": "#F47721",
        "hiring_programs": [
            {"id": "fresh_sde1", "name": "Software Development Engineer I", "role": "Software Engineer", "package_lpa": "15 - 26 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "Machine coding (Multi-tenant ticket routing LLD), LeetCode Medium DSA, web performance, SaaS culture.", "typical_rounds": ["Online Coding Test", "Machine Coding (2 Hours LLD)", "DSA & Web Concepts", "Freshworks Culture"]}
        ]
    },
    {
        "id": "comp_persistent", "name": "Persistent Systems", "short_name": "Persistent", "category": "Product Engineering & IT", "color_hex": "#EC1C24",
        "hiring_programs": [
            {"id": "persistent_se", "name": "Software Engineer", "role": "Software Engineer", "package_lpa": "4.7 - 9.0 LPA", "difficulty": "Medium to Hard", "rounds_count": 3, "overview": "CS fundamentals (OS, DBMS, Data Structures), hands-on coding, cloud architecture, project defense.", "typical_rounds": ["Persistent Online Test", "Technical 1: DSA & OS", "Technical & HR Leadership"]}
        ]
    },
    {
        "id": "comp_meesho", "name": "Meesho", "short_name": "Meesho", "category": "Product / E-Commerce Unicorn", "color_hex": "#F43397",
        "hiring_programs": [
            {"id": "meesho_sde1", "name": "SDE I", "role": "Software Engineer", "package_lpa": "20 - 32 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "Machine coding (Reseller Order Allocation LLD), data structures, high scale e-commerce architecture.", "typical_rounds": ["Online Coding Challenge", "Machine Coding (2 Hours LLD)", "DSA Optimization", "Culture Alignment"]}
        ]
    },
    {
        "id": "comp_ola", "name": "Ola", "short_name": "Ola", "category": "Product / Mobility & EV", "color_hex": "#000000",
        "hiring_programs": [
            {"id": "ola_sde1", "name": "SDE I", "role": "Software Engineer", "package_lpa": "18 - 28 LPA", "difficulty": "Hard", "rounds_count": 4, "overview": "Geospatial calculations, graph algorithms, low-level ride matching system design, fast execution.", "typical_rounds": ["Online Qualifier", "Low-Level Design", "DSA & Graph Algorithms", "HR Panel"]}
        ]
    }
]

# --- NEW EXTENDED COMPANIES (COMPANIES 39 TO 115+) ---
NEW_INDIAN_AND_GLOBAL_COMPANIES = [
    # Quick Commerce & Consumer Tech (39-44)
    ("comp_zepto", "Zepto", "Zepto", "Quick Commerce Unicorn", "#7A22A6", "18 - 30 LPA", ["Coding Assessment", "Machine Coding (Inventory LLD)", "DSA & System Concepts", "HR Round"]),
    ("comp_blinkit", "Blinkit", "Blinkit", "Quick Commerce Unicorn", "#F4C430", "18 - 32 LPA", ["Online Qualifier", "Low Level Design", "Problem Solving", "Managerial"]),
    ("comp_urbancompany", "Urban Company", "Urban Company", "Consumer Tech Unicorn", "#000000", "16 - 28 LPA", ["HackerRank Qualifier", "Machine Coding", "DSA Deep Dive", "Culture Fit"]),
    ("comp_groww", "Groww", "Groww", "Fintech Unicorn", "#00D09C", "20 - 35 LPA", ["Online Assessment", "Machine Coding (Trading Engine LLD)", "Concurrency & DB Transactions", "Bar Raiser"]),
    ("comp_zerodha", "Zerodha", "Zerodha", "Fintech Giant", "#387ED1", "18 - 30 LPA", ["Coding Challenge", "Low Level Architecture", "Go/Python Systems", "Founders Round"]),
    ("comp_upstox", "Upstox", "Upstox", "Fintech Unicorn", "#6C5CE7", "16 - 26 LPA", ["Online Test", "Machine Coding", "DSA & Concurrency", "HR Interview"]),

    # E-Commerce, Travel & Ticketing (45-52)
    ("comp_policybazaar", "PolicyBazaar", "PolicyBazaar", "Fintech / InsurTech", "#003366", "12 - 22 LPA", ["Aptitude & Coding", "Technical Round 1", "Technical Round 2", "HR Panel"]),
    ("comp_nykaa", "Nykaa", "Nykaa", "E-Commerce / Fashion", "#FC2779", "14 - 24 LPA", ["Online Qualifier", "Machine Coding", "Problem Solving", "HR Round"]),
    ("comp_makemytrip", "MakeMyTrip", "MakeMyTrip", "Travel Tech Giant", "#E41D24", "16 - 28 LPA", ["Coding Test", "Low Level Design", "DSA & Database Optimization", "Managerial"]),
    ("comp_bookmyshow", "BookMyShow", "BookMyShow", "Entertainment Tech", "#C82333", "12 - 22 LPA", ["Online Assessment", "Machine Coding (Seat Allocation)", "Core CS & SQL", "HR Interview"]),
    ("comp_cars24", "Cars24", "Cars24", "AutoTech Unicorn", "#FF6B00", "14 - 25 LPA", ["Online Coding", "Machine Coding", "DSA & Systems", "Managerial"]),
    ("comp_spinny", "Spinny", "Spinny", "AutoTech Unicorn", "#004B87", "14 - 24 LPA", ["Online Test", "Machine Coding", "DSA Round", "HR Round"]),
    ("comp_pinelabs", "Pine Labs", "Pine Labs", "Fintech Merchant SaaS", "#008080", "16 - 28 LPA", ["Coding Test", "Machine Coding (POS Transaction)", "DB Consistency", "HR Panel"]),
    ("comp_billdesk", "BillDesk", "BillDesk", "Fintech Payments", "#002B49", "12 - 20 LPA", ["Online Assessment", "Technical Round 1", "Technical Round 2", "HR Panel"]),

    # EdTech & Social Media Content (53-61)
    ("comp_physicswallah", "PhysicsWallah", "PW", "EdTech Unicorn", "#1B1B1B", "12 - 22 LPA", ["Online Test", "Technical Coding", "System Architecture", "HR Interview"]),
    ("comp_unacademy", "Unacademy", "Unacademy", "EdTech Unicorn", "#08BD80", "15 - 26 LPA", ["Online Qualifier", "Machine Coding", "DSA Deep Dive", "Managerial"]),
    ("comp_eruditus", "Eruditus", "Eruditus", "EdTech Unicorn", "#13294B", "14 - 24 LPA", ["Online Test", "Technical 1", "Technical 2", "HR Panel"]),
    ("comp_sharechat", "ShareChat", "ShareChat", "Social Media Unicorn", "#FF8C00", "22 - 38 LPA", ["Online Assessment", "Machine Coding", "DSA & Distributed Systems", "Culture Fit"]),
    ("comp_pocketfm", "Pocket FM", "Pocket FM", "Audio Streaming Unicorn", "#E50914", "18 - 30 LPA", ["Online Qualifier", "Machine Coding", "DSA & Systems", "Managerial"]),
    ("comp_inmobi", "InMobi", "InMobi", "AdTech Unicorn", "#1A73E8", "20 - 35 LPA", ["HackerRank Challenge", "Machine Coding", "DSA & Data Architecture", "Bar Raiser"]),
    ("comp_glance", "Glance", "Glance", "Consumer Tech Unicorn", "#00E676", "20 - 32 LPA", ["Online Test", "Machine Coding", "Problem Solving", "HR Interview"]),
    ("comp_verse", "Dailyhunt (VerSe)", "Dailyhunt", "Media Tech Unicorn", "#FF3D00", "16 - 28 LPA", ["Online Qualifier", "Machine Coding", "DSA & Systems", "Managerial"]),
    ("comp_mpl", "Mobile Premier League", "MPL", "Gaming Unicorn", "#D32F2F", "18 - 32 LPA", ["Online Test", "Machine Coding (Matchmaking LLD)", "Concurrency", "Culture Fit"]),

    # Gaming & D2C Brands (62-67)
    ("comp_dream11", "Dream11", "Dream11", "Sports Tech Unicorn", "#E10600", "22 - 40 LPA", ["Online Qualifier", "Machine Coding (Leaderboard LLD)", "High Scale HLD", "Bar Raiser"]),
    ("comp_games24x7", "Games24x7", "Games24x7", "Gaming Unicorn", "#1E88E5", "18 - 32 LPA", ["Online Assessment", "Machine Coding", "DSA & System Concepts", "Managerial"]),
    ("comp_winzo", "WinZO", "WinZO", "Gaming Tech", "#FFB300", "14 - 25 LPA", ["Coding Test", "Machine Coding", "DSA Round", "HR Panel"]),
    ("comp_lenskart", "Lenskart", "Lenskart", "D2C Retail Unicorn", "#000042", "14 - 26 LPA", ["Online Qualifier", "Machine Coding", "DSA & Web Concepts", "HR Interview"]),
    ("comp_firstcry", "FirstCry", "FirstCry", "E-Commerce Giant", "#FF4081", "12 - 22 LPA", ["Online Assessment", "Technical 1", "Technical 2", "HR Panel"]),
    ("comp_shiprocket", "Shiprocket", "Shiprocket", "Logistics Tech Unicorn", "#4E2A84", "15 - 26 LPA", ["Online Qualifier", "Machine Coding", "DSA & SQL", "Managerial"]),

    # Logistics & B2B Platforms (68-73)
    ("comp_delhivery", "Delhivery", "Delhivery", "Logistics Tech Giant", "#232F3E", "16 - 28 LPA", ["Online Qualifier", "Machine Coding (Route Optimization LLD)", "DSA", "Hiring Manager"]),
    ("comp_shadowfax", "Shadowfax", "Shadowfax", "Logistics Tech", "#FB8C00", "12 - 22 LPA", ["Online Test", "Technical 1", "Technical 2", "HR Panel"]),
    ("comp_porter", "Porter", "Porter", "Logistics Tech Unicorn", "#1976D2", "14 - 25 LPA", ["Online Qualifier", "Machine Coding", "DSA & DB Design", "Managerial"]),
    ("comp_udaan", "Udaan", "Udaan", "B2B E-Commerce Unicorn", "#388E3C", "18 - 30 LPA", ["Online Challenge", "Machine Coding", "DSA & Distributed Systems", "Culture Fit"]),
    ("comp_moglix", "Moglix", "Moglix", "B2B E-Commerce Unicorn", "#C2185B", "14 - 24 LPA", ["Online Assessment", "Technical 1", "Technical 2", "HR Round"]),
    ("comp_zetwerk", "Zetwerk", "Zetwerk", "Manufacturing Tech Unicorn", "#00796B", "16 - 28 LPA", ["Online Test", "Machine Coding", "DSA & Systems", "Managerial"]),

    # SaaS & B2B Software Unicorns (74-83)
    ("comp_highradius", "HighRadius", "HighRadius", "Fintech SaaS Unicorn", "#0D47A1", "12 - 22 LPA", ["Online Test", "Technical 1: Java/SQL", "Technical 2: Projects", "HR Panel"]),
    ("comp_postman", "Postman", "Postman", "API Platform Unicorn", "#FF6C37", "24 - 45 LPA", ["HackerRank Qualifier", "Code Craft / API Design", "System Architecture", "Values Round"]),
    ("comp_chargebee", "Chargebee", "Chargebee", "Subscription SaaS Unicorn", "#4A154B", "18 - 30 LPA", ["Online Qualifier", "Machine Coding", "DSA & Web Architecture", "Managerial"]),
    ("comp_hackerrank", "HackerRank", "HackerRank", "Dev Tools SaaS", "#2EC4B6", "18 - 32 LPA", ["HackerRank Challenge", "Code Craft", "System Design", "Cultural Alignment"]),
    ("comp_scaler", "Scaler / InterviewBit", "Scaler", "EdTech / Dev Tools", "#2B2D42", "18 - 32 LPA", ["Online Qualifier", "DSA Deep Dive", "System Design", "Managerial"]),
    ("comp_browserstack", "BrowserStack", "BrowserStack", "Dev Tools Unicorn", "#00B4D8", "20 - 36 LPA", ["Online Qualifier", "Machine Coding (Browser Engine LLD)", "DSA & Systems", "Bar Raiser"]),
    ("comp_hasura", "Hasura", "Hasura", "GraphQL SaaS Unicorn", "#1EB4D4", "22 - 40 LPA", ["Coding Challenge", "Compiler/GraphQL Systems", "DSA & Architecture", "Founders Round"]),
    ("comp_darwinbox", "Darwinbox", "Darwinbox", "HR Tech SaaS Unicorn", "#6C5CE7", "15 - 26 LPA", ["Online Qualifier", "Machine Coding", "DSA & Database Design", "Managerial"]),
    ("comp_icertis", "Icertis", "Icertis", "Enterprise SaaS Unicorn", "#005691", "14 - 24 LPA", ["Online Test", "Technical 1", "Technical 2", "HR Panel"]),
    ("comp_innovaccer", "Innovaccer", "Innovaccer", "HealthTech Unicorn", "#00A86B", "18 - 30 LPA", ["Online Qualifier", "Machine Coding", "DSA & Systems", "Managerial"]),

    # HealthTech & Wellness (84-86)
    ("comp_pharmeasy", "PharmEasy", "PharmEasy", "HealthTech Unicorn", "#108276", "14 - 25 LPA", ["Online Qualifier", "Machine Coding", "DSA & DB Design", "Managerial"]),
    ("comp_tata1mg", "Tata 1mg", "Tata 1mg", "HealthTech Giant", "#FF6F61", "15 - 26 LPA", ["Online Test", "Machine Coding", "DSA & System Concepts", "HR Panel"]),
    ("comp_cultfit", "Cult.fit", "Cult.fit", "Fitness & HealthTech", "#FF3366", "16 - 28 LPA", ["Online Qualifier", "Machine Coding", "DSA Round", "Managerial"]),

    # Indian Corporate Tech Divisions (87-92)
    ("comp_airtel", "Bharti Airtel (Xlabs)", "Airtel Xlabs", "Telecom Tech Giant", "#E40000", "14 - 25 LPA", ["Online Test", "Technical 1: Core CS & Networking", "Technical 2: Cloud Systems", "HR Panel"]),
    ("comp_tataneu", "Tata Digital (Tata Neu)", "Tata Digital", "E-Commerce SuperApp", "#5C0632", "18 - 30 LPA", ["Online Qualifier", "Machine Coding", "DSA & Systems", "Managerial"]),
    ("comp_bajajfinserv", "Bajaj Finserv Health", "Bajaj Finserv", "Fintech Giant", "#00529B", "12 - 22 LPA", ["Online Assessment", "Technical 1", "Technical 2", "HR Panel"]),
    ("comp_hdfc", "HDFC Bank Digital", "HDFC Digital", "Banking Tech", "#004B8D", "10 - 18 LPA", ["Online Aptitude & Coding", "Technical Panel", "HR Interview"]),
    ("comp_icicibank", "ICICI Bank Tech", "ICICI Tech", "Banking Tech", "#F37023", "9 - 16 LPA", ["Online Test", "Technical Panel", "HR Interview"]),
    ("comp_kotak", "Kotak 811 Tech", "Kotak 811", "Banking Tech", "#ED1C24", "12 - 20 LPA", ["Online Assessment", "Technical 1", "Technical 2", "HR Panel"]),

    # Global Investment Banking & Financial MNCs (93-100)
    ("comp_morganstanley", "Morgan Stanley", "Morgan Stanley", "Investment Banking", "#002A54", "22 - 36 LPA", ["Online OA (Math + Coding)", "Technical 1: DSA", "Technical 2: Systems & C++", "Director Panel"]),
    ("comp_barclays", "Barclays", "Barclays", "Investment Banking", "#00AEA9", "16 - 26 LPA", ["Online Hackerrank", "Technical 1: Java/Spring & SQL", "Technical 2: System Design", "Values Round"]),
    ("comp_wellsfargo", "Wells Fargo", "Wells Fargo", "Financial Services MNC", "#D71E28", "16 - 26 LPA", ["Online Test", "Technical 1: DSA & SQL", "Technical 2: Java/Python", "Managerial"]),
    ("comp_amex", "American Express", "Amex", "Fintech & Cards MNC", "#006FCF", "18 - 30 LPA", ["Online Test", "Technical 1: DSA & Logic", "Technical 2: DB Transactions", "HR Panel"]),
    ("comp_paypal", "PayPal", "PayPal", "Fintech MNC", "#003087", "22 - 38 LPA", ["Online Qualifier", "Machine Coding", "DSA & Transactions", "Bar Raiser"]),
    ("comp_stripe", "Stripe", "Stripe", "Fintech SaaS MNC", "#635BFF", "35 - 65 LPA", ["Bug Fix Screen", "System Design & API Integration", "Coding Craft", "Culture Fit"]),
    ("comp_visa", "Visa", "Visa", "Payments Tech MNC", "#1A1F71", "18 - 32 LPA", ["Online OA", "Technical 1: DSA & Sockets", "Technical 2: Payments Architecture", "Managerial"]),
    ("comp_mastercard", "Mastercard", "Mastercard", "Payments Tech MNC", "#FF5F00", "18 - 30 LPA", ["Online Test", "Technical 1: Core CS & Java", "Technical 2: System Security", "HR Panel"]),

    # Semiconductor, Hardware & Electronics MNCs (101-107)
    ("comp_intel", "Intel", "Intel", "Semiconductor MNC", "#0071C5", "16 - 28 LPA", ["Online Assessment", "Technical 1: C/C++, OS & Pointers", "Technical 2: Architecture", "HR Panel"]),
    ("comp_amd", "AMD", "AMD", "Semiconductor MNC", "#ED1C24", "16 - 28 LPA", ["Online Test", "Technical 1: C/C++ & Microprocessors", "Technical 2: Memory Layout", "Managerial"]),
    ("comp_nvidia", "Nvidia", "Nvidia", "AI Hardware & Compute", "#76B900", "28 - 50 LPA", ["Online Screening", "Technical 1: C++, CUDA & Memory", "Technical 2: GPU Systems", "Director Round"]),
    ("comp_qualcomm", "Qualcomm", "Qualcomm", "Wireless & Embedded MNC", "#3253DC", "18 - 32 LPA", ["Online OA (C MCQs + Coding)", "Technical 1: C/C++ & OS Kernel", "Technical 2: Embedded Systems", "HR Panel"]),
    ("comp_samsung", "Samsung R&D (SSIR)", "Samsung R&D", "Electronics & SW MNC", "#1428A0", "16 - 28 LPA", ["Samsung Advanced SW Competency Test (3 hrs 1 problem)", "Technical 1: DSA & OS", "Technical 2: System Code", "HR Panel"]),
    ("comp_sony", "Sony India Software", "Sony", "Software & Media MNC", "#000000", "12 - 22 LPA", ["Online Test", "Technical 1: C++/Python & DSA", "Technical 2: Systems", "HR Panel"]),
    ("comp_bosch", "Bosch (RBEI)", "Bosch", "Engineering Tech MNC", "#EA0016", "10 - 18 LPA", ["Online Aptitude & Tech MCQs", "Technical 1: C/C++ & Embedded", "Technical 2: Projects", "HR Panel"]),

    # Global Enterprise SaaS & Cloud MNCs (108-115)
    ("comp_sap", "SAP Labs India", "SAP", "Enterprise Software MNC", "#008FD3", "16 - 28 LPA", ["Online Hackerrank", "Technical 1: Data Structures & OOP", "Technical 2: System Architecture", "HR & Managerial"]),
    ("comp_vmware", "VMware (Broadcom)", "VMware", "Cloud & Virtualization", "#607D8B", "20 - 35 LPA", ["Online OA", "Technical 1: OS, Networking & Memory", "Technical 2: Virtualization LLD", "Managerial"]),
    ("comp_servicenow", "ServiceNow", "ServiceNow", "Enterprise SaaS MNC", "#293E40", "22 - 38 LPA", ["Online Test", "Technical 1: DSA & JS/Java", "Technical 2: System Architecture", "Bar Raiser"]),
    ("comp_intuit", "Intuit", "Intuit", "Fintech SaaS MNC", "#0077C5", "24 - 42 LPA", ["Karat Tech Screen", "Craft Demo / Live System Coding", "DSA & Architecture", "Values Round"]),
    ("comp_paloalto", "Palo Alto Networks", "Palo Alto", "Cybersecurity MNC", "#FA4616", "22 - 40 LPA", ["Online OA", "Technical 1: Networking & Sockets", "Technical 2: Systems & C++/Go", "Managerial"]),
    ("comp_snowflake", "Snowflake", "Snowflake", "Data Cloud MNC", "#29B5E8", "35 - 65 LPA", ["Online Challenge", "Technical 1: Distributed Systems & DSA", "Technical 2: Database Internals", "Director Round"]),
    ("comp_databricks", "Databricks", "Databricks", "Data & AI MNC", "#FF3621", "35 - 65 LPA", ["Coding Screen", "System Architecture & Spark/C++", "DSA & Optimization", "Bar Raiser"]),
    ("comp_mongodb", "MongoDB", "MongoDB", "Database Systems MNC", "#13AA52", "25 - 45 LPA", ["Online Test", "Technical 1: Database Engine Mechanics & DSA", "Technical 2: Systems Coding", "Culture Fit"])
]

# Generate missing entries
for item in NEW_INDIAN_AND_GLOBAL_COMPANIES:
    cid, cname, sname, cat, color, pkg, rounds = item
    EXPANDED_COMPANIES_CATALOG.append({
        "id": cid,
        "name": cname,
        "short_name": sname,
        "category": cat,
        "color_hex": color,
        "hiring_programs": [
            {
                "id": f"{cid}_track",
                "name": f"{sname} Software Engineering Track",
                "role": "Software Development Engineer",
                "package_lpa": pkg,
                "difficulty": "Medium to Hard" if "Unicorn" in cat or "MNC" in cat else "Hard",
                "rounds_count": len(rounds),
                "overview": f"Comprehensive verified recruitment track for {cname} evaluating core DSA, system design, database optimization, and cultural alignment.",
                "typical_rounds": rounds
            }
        ]
    })
