import type { QuestionItem, ResumeRisk, BulletRewrite, PdfRiskHighlight, ResumeQuestion, CompanyItem, Flashcard } from './types';

export const MOCK_QUESTIONS: QuestionItem[] = [
  {
    id: 'q1',
    title: 'Write an algorithm to detect a cycle in a directed graph',
    difficulty: 'Medium',
    category: 'Graph Theory',
    topics: ['DFS', 'Graph', 'Cycle Detection', 'Topological Sort'],
    source: 'Question Bank',
    description: 'Graph Cycle Detection Algorithm: 1. Maintain a state array of size V initialized to 0. 2. Iterate through all vertices i from 0 to V-1. If state[i] == 0, launch dfs(i). 3. Inside dfs(u): mark state[u] = 1 (Visiting). For each neighbor v: if state[v] == 1, return True (cycle detected!). If state[v] == 0 and dfs(v) returns True, return True. 4. After exploring all neighbors, mark state[u] = 2 (Visited) and return False.',
    codeExample: `# Python 3 Solution for Graph Cycle Detection
def has_cycle(V, adj):
    state = [0] * V # 0: Unvisited, 1: Visiting, 2: Visited
    
    def dfs(u):
        state[u] = 1
        for v in adj[u]:
            if state[v] == 1:
                return True
            if state[v] == 0 and dfs(v):
                return True
        state[u] = 2
        return False

    for i in range(V):
        if state[i] == 0:
            if dfs(i):
                return True
    return False`,
    complexity: 'O(V + E) Time | O(V) Space',
    company: 'Google / Amazon',
  },
  {
    id: 'q2',
    title: 'LRU Cache Implementation',
    difficulty: 'Hard',
    category: 'System Design / Data Structures',
    topics: ['Hash Map', 'Doubly Linked List', 'Design'],
    source: 'LeetCode',
    description: 'Design a data structure that follows the constraints of a Least Recently Used (LRU) cache with O(1) get and put time complexities.',
    codeExample: `# LRU Cache implementation using HashMap + DoublyLinkedList
class LRUCache:
    def __init__(self, capacity: int):
        self.cap = capacity
        self.cache = {}
        # doubly linked list logic...
        pass`,
    complexity: 'O(1) Time | O(Capacity) Space',
    acceptanceRate: '41.2%',
    company: 'Meta / Microsoft',
  },
  {
    id: 'q3',
    title: 'Find Top N Highest Salary Employees Per Department',
    difficulty: 'Medium',
    category: 'PostgreSQL',
    topics: ['SQL', 'Window Functions', 'DENSE_RANK', 'GROUP BY'],
    source: 'Question Bank',
    description: 'Write a SQL query to find employees who earn the top 3 highest salaries in each of the department table.',
    codeExample: `-- PostgreSQL Query Solution
WITH RankedSalaries AS (
    SELECT 
        d.name AS Department,
        e.name AS Employee,
        e.salary AS Salary,
        DENSE_RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) as rk
    FROM Employee e
    JOIN Department d ON e.department_id = d.id
)
SELECT Department, Employee, Salary
FROM RankedSalaries
WHERE rk <= 3;`,
    complexity: 'O(N log N) Time | O(N) Space',
    company: 'Uber / Stripe',
  },
  {
    id: 'q4',
    title: 'Async Promise Sequential Execution Engine',
    difficulty: 'Medium',
    category: 'JavaScript',
    topics: ['Promises', 'Async/Await', 'Event Loop'],
    source: 'LeetCode',
    description: 'Given an array of asynchronous functions, execute them sequentially one after another and return an array of resolved values.',
    codeExample: `// JavaScript Solution
async function executeSequentially(asyncTasks) {
    const results = [];
    for (const task of asyncTasks) {
        const res = await task();
        results.push(res);
    }
    return results;
}`,
    complexity: 'O(N) Time | O(N) Space',
    company: 'Netflix / Apple',
  }
];

export const MOCK_RISKS: ResumeRisk[] = [
  {
    id: 'r1',
    title: "Skill 'Kubernetes' Listed Without Project Evidence",
    claimedItem: 'Kubernetes',
    riskLevel: 'High',
    evidenceSource: 'Skills Section',
    evidenceText: "'Kubernetes' is listed under Cloud & DevOps skills",
    whyQuestioned: "'Kubernetes' is explicitly listed under Skills, but no project or work experience in the resume details how you deployed or managed clusters with Kubernetes.",
    interviewerProbe: 'Which specific kubectl commands, ingress controllers, or Helm charts have you configured hands-on in production?',
    preparationAdvice: 'Be prepared to detail your hands-on experience with Kubernetes or clarify your familiarity level.',
    starDefense: {
      situation: 'When asked about Kubernetes, frame the cluster deployment required for microservice auto-scaling.',
      task: 'Explain your specific responsibility configuring Deployment manifests & horizontal pod autoscalers (HPA).',
      action: 'Detail how you wrote Helm templates, configured readiness/liveness probes, and integrated ingress rules.',
      result: 'Highlight zero-downtime rolling updates and 99.99% pod reliability.'
    }
  },
  {
    id: 'r2',
    title: 'Architectural Claim Requires Quantitative Metrics: Primary Technical Application',
    claimedItem: 'Primary Technical Application',
    riskLevel: 'Medium',
    evidenceSource: 'Project: E-Commerce Microservices Engine',
    evidenceText: '"Built microservice backend utilizing FastAPI, Docker, and PostgreSQL."',
    whyQuestioned: 'The project claim outlines technical scope but lacks quantifiable impact metrics (e.g. API latency reduction, QPS, user scale).',
    interviewerProbe: 'What was your average p95 response latency, and how many concurrent requests/sec did your database pool sustain?',
    preparationAdvice: 'Prepare specific metrics (e.g., 35% response speedup, 5,000+ daily active users) to back up your claim.',
    starDefense: {
      situation: 'Set the traffic scale and latency goals for your FastAPI microservices.',
      task: 'Outline your responsibility for API throughput and database query optimization.',
      action: 'Walk through implementing connection pooling, Redis caching, and async endpoints.',
      result: 'Demonstrate 35% latency drop from 180ms to 115ms under 1,000 QPS load.'
    }
  }
];

export const MOCK_REWRITES: BulletRewrite[] = [
  {
    originalBullet: 'Developed application using Python and PostgreSQL database.',
    starBullet: 'Architected 10+ RESTful microservices using Python and PostgreSQL with connection pooling, reducing p99 API latency by 35%.',
    googleXyzBullet: 'Accomplished 35% reduction in p99 API latency as measured by Datadog APM metrics by architecting 10+ microservices using Python and PostgreSQL.',
    actionImpactBullet: 'Spearheaded 10+ high-throughput Python REST services with PostgreSQL connection pooling, driving a 35% latency drop.',
    whyBetter: 'Replaces passive phrasing with strong action verb ("Architected") and adds quantitative latency impact.',
    quantifiedImpact: '35% Latency Reduction (p99)'
  },
  {
    originalBullet: 'Worked on project UI and API backend integration.',
    starBullet: 'Engineered responsive user interface and integrated robust JWT-authenticated REST APIs with SQL, supporting 5,000+ daily active users.',
    googleXyzBullet: 'Accomplished 99.9% uptime for 5,000+ daily active users as measured by OAuth2 JWT telemetry by engineering responsive UI and backend API integration.',
    actionImpactBullet: 'Built & scaled responsive UI with JWT-authenticated SQL backend endpoints, serving 5,000+ DAU.',
    whyBetter: 'Quantifies scale (5,000+ DAU) and details security & API architecture mechanics.',
    quantifiedImpact: '5,000+ Daily Active Users'
  },
  {
    originalBullet: 'Handled code testing and database query execution.',
    starBullet: 'Optimized SQL query execution plans and implemented automated pytest suites, improving query throughput by 45%.',
    googleXyzBullet: 'Accomplished 45% throughput increase as measured by SQL query execution benchmark suite by implementing automated pytest suites and query tuning.',
    actionImpactBullet: 'Revamped database query execution pipelines and automated pytest coverage, boosting system query throughput by 45%.',
    whyBetter: 'Highlights performance tuning metrics and automated testing best practices.',
    quantifiedImpact: '45% Throughput Gain'
  }
];

export const MOCK_PDF_HIGHLIGHTS: PdfRiskHighlight[] = [
  {
    id: 'rh_0',
    page: 1,
    severity: 'high_warning',
    claimText: "Technical Skills: Kubernetes, Docker, AWS, FastAPI",
    xPercent: 12.0,
    yPercent: 24.5,
    widthPercent: 76.0,
    heightPercent: 4.0,
    flagCategory: "Skill 'Kubernetes' Listed Without Project Evidence",
    whyFlagged: "'Kubernetes' is listed under Technical Skills, but no project details cluster deployments.",
    interviewerProbe: 'Which specific Helm charts or ingress controllers have you configured in production?',
    suggestedRewrite: 'Be prepared to detail your hands-on experience with Kubernetes or clarify your familiarity level.'
  },
  {
    id: 'rh_1',
    page: 1,
    severity: 'medium_warning',
    claimText: "Built microservices using FastAPI, Docker, and PostgreSQL",
    xPercent: 12.0,
    yPercent: 48.0,
    widthPercent: 76.0,
    heightPercent: 4.5,
    flagCategory: "Architectural Claim Requires Quantitative Metrics",
    whyFlagged: "Description lacks quantifiable metrics (e.g. latency, throughput, QPS).",
    interviewerProbe: "What was your average API response latency under load?",
    suggestedRewrite: "Add quantifiable impact metrics (e.g. 35% latency drop, 1,000 QPS)."
  }
];

export const MOCK_RESUME_QUESTIONS: ResumeQuestion[] = [
  {
    id: 'q_0',
    category: 'High Probability',
    question: "How did you design the database schema and query index for your primary project?",
    whyAsked: "Interviewers evaluate your data modeling skills, normalization vs denormalization choices, and indexing strategies.",
    modelAnswer: "I normalized core entities into 3NF to ensure data integrity, while creating B-Tree composite indexes on (user_id, created_at) to accelerate our most frequent time-series query from 240ms down to 12ms.",
    keyTopics: ['Indexing', '3NF Normalization', 'Composite Indexes', 'Query Optimization']
  },
  {
    id: 'q_1',
    category: 'Technical Deep Dive',
    question: "Walk me through how you handled concurrency and thread safety in your backend API.",
    whyAsked: "Validates your understanding of race conditions, optimistic vs pessimistic locking, and connection pooling.",
    modelAnswer: "We implemented PostgreSQL SELECT FOR UPDATE row locking during transactional inventory deduction and utilized Redis distributed locks for idempotency across worker instances.",
    keyTopics: ['Row Locking', 'Redis Distributed Locks', 'Idempotency', 'Concurrency']
  }
];

export const MOCK_COMPANIES: CompanyItem[] = [
  {
    id: 'c1',
    name: 'Google',
    logoUrl: '🌐',
    category: 'FAANG / Big Tech',
    difficulty: 'Hard',
    location: 'Mountain View, CA / Remote',
    activeRoles: 42,
    stages: ['Online Coding Assessment (2 Qs)', 'Technical Phone Screen (45m)', 'Full Onsite (3 Tech + 1 System Design + 1 Googlyness)'],
    sampleQuestions: ['Detect Cycle in Directed Graph', 'Serialize and Deserialize Binary Tree', 'Design Google Drive Rate Limiter']
  },
  {
    id: 'c2',
    name: 'Amazon',
    logoUrl: '📦',
    category: 'FAANG / E-Commerce & Cloud',
    difficulty: 'Medium-Hard',
    location: 'Seattle, WA / Hybrid',
    activeRoles: 85,
    stages: ['OA (Debug + Coding + Work Simulation)', 'Phone Technical Screen', 'Onsite Loop (4 Interviews with Leadership Principles)'],
    sampleQuestions: ['LRU Cache Implementation', 'Reorganize String', 'Design Amazon Fulfillment Order Tracker']
  },
  {
    id: 'c3',
    name: 'Stripe',
    logoUrl: '💳',
    category: 'FinTech / High Growth',
    difficulty: 'Hard',
    location: 'San Francisco, CA / Remote',
    activeRoles: 18,
    stages: ['Bug Fix Coding Screen', 'Practical API Integration Test', 'Onsite (System Architecture, Code Review, Past Project)'],
    sampleQuestions: ['Implement Payment Idempotency Engine', 'Parse Merchant Invoice Rules', 'Design High-Throughput Ledger']
  }
];

export const MOCK_FLASHCARDS: Flashcard[] = [
  {
    id: 'f1',
    category: 'System Design',
    question: 'What is the difference between Strong Consistency and Eventual Consistency?',
    answer: 'Strong Consistency guarantees that any read operation immediately returns the latest written value across all nodes (ACID/CP). Eventual Consistency guarantees that if no new updates occur, all replicas will eventually converge to the same data (BASE/AP), sacrificing immediate sync for higher availability and lower latency.',
    codeSnippet: '// Strong: R + W > N (Quorum)\n// Eventual: DynamoDB / Cassandra default'
  },
  {
    id: 'f2',
    category: 'Algorithms',
    question: 'How does Topological Sort work in a Directed Acyclic Graph (DAG)?',
    answer: 'Topological Sort orders vertices linearly such that for every directed edge u -> v, u comes before v. It can be implemented using Kahns Algorithm (BFS with In-degree count) or DFS (post-order traversal pushed to a stack).',
    codeSnippet: '# Kahn\'s Algorithm BFS:\nqueue = deque([u for u in range(V) if in_degree[u] == 0])'
  }
];
