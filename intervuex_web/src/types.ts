export type ThemeVariant = 'ocean' | 'purple' | 'emerald' | 'sunset' | 'rose' | 'midnight';
export type ThemeMode = 'dark' | 'light';
export type Language = 'en' | 'hi' | 'es' | 'fr' | 'de';

export interface ThemeVariantColors {
  name: string;
  primary: string;
  light: string;
  gradientEnd: string;
  gradient: string;
}

export interface QuestionItem {
  id: string;
  title: string;
  difficulty: 'Easy' | 'Medium' | 'Hard';
  category: string;
  topics: string[];
  source: 'Question Bank' | 'LeetCode';
  description: string;
  codeExample?: string;
  complexity?: string;
  link?: string;
  acceptanceRate?: string;
  company?: string;
}

export interface ResumeRisk {
  id: string;
  title: string;
  claimedItem: string;
  riskLevel: 'High' | 'Medium' | 'Low';
  evidenceSource: string;
  evidenceText: string;
  whyQuestioned: string;
  interviewerProbe: string;
  preparationAdvice: string;
  starDefense: {
    situation: string;
    task: string;
    action: string;
    result: string;
  };
}

export interface BulletRewrite {
  originalBullet: string;
  starBullet: string;
  googleXyzBullet: string;
  actionImpactBullet: string;
  whyBetter: string;
  quantifiedImpact?: string;
}

export interface PdfRiskHighlight {
  id: string;
  page: number;
  severity: string;
  claimText: string;
  xPercent: number;
  yPercent: number;
  widthPercent: number;
  heightPercent: number;
  flagCategory: string;
  whyFlagged: string;
  interviewerProbe: string;
  suggestedRewrite: string;
}

export interface ResumeQuestion {
  id: string;
  category: string;
  question: string;
  whyAsked: string;
  modelAnswer: string;
  keyTopics: string[];
}

export interface CompanyItem {
  id: string;
  name: string;
  logoUrl: string;
  category: string;
  difficulty: string;
  location: string;
  activeRoles: number;
  stages: string[];
  sampleQuestions: string[];
}

export interface Flashcard {
  id: string;
  category: string;
  question: string;
  answer: string;
  codeSnippet?: string;
}
