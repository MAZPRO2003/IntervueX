import React, { useState } from 'react';
import { ThemeProvider, useTheme } from './context/ThemeContext';
import { Header } from './components/Header';
import { HomeView } from './views/HomeView';
import { CodeSandboxView } from './views/CodeSandboxView';
import { ResumeAnalyzerView } from './views/ResumeAnalyzerView';
import { MockInterviewView } from './views/MockInterviewView';
import { CompaniesView } from './views/CompaniesView';
import { JobAnalyzerView } from './views/JobAnalyzerView';
import { PacksView } from './views/PacksView';
import { QuestionBankView } from './views/QuestionBankView';
import { FlashcardsView } from './views/FlashcardsView';
import { StudyPlanView } from './views/StudyPlanView';
import { ProfileView } from './views/ProfileView';
import type { QuestionItem } from './types';

const AppContent: React.FC = () => {
  const { mode } = useTheme();
  const [activeTab, setActiveTab] = useState<string>('home');
  const [selectedQuestion, setSelectedQuestion] = useState<QuestionItem | null>(null);

  const renderView = () => {
    switch (activeTab) {
      case 'sandbox':
        return <CodeSandboxView selectedQuestion={selectedQuestion} />;
      case 'resume':
        return <ResumeAnalyzerView />;
      case 'mock':
        return <MockInterviewView />;
      case 'companies':
        return <CompaniesView />;
      case 'job-analyzer':
        return <JobAnalyzerView />;
      case 'packs':
        return <PacksView />;
      case 'questions':
        return (
          <QuestionBankView
            onSelectQuestion={(q) => setSelectedQuestion(q)}
            onNavigate={(tab) => setActiveTab(tab)}
          />
        );
      case 'flashcards':
        return <FlashcardsView />;
      case 'study-plan':
        return <StudyPlanView />;
      case 'profile':
        return <ProfileView />;
      case 'home':
      default:
        return (
          <HomeView
            onNavigate={(tab) => setActiveTab(tab)}
            onSelectQuestion={(q) => setSelectedQuestion(q)}
          />
        );
    }
  };

  return (
    <div className={`min-h-screen font-sans ${mode === 'dark' ? 'bg-[#0B0F19] text-[#F8FAFC]' : 'bg-[#F8FAFC] text-[#0F172A]'}`}>
      <Header activeTab={activeTab} setActiveTab={setActiveTab} />
      
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-6">
        {renderView()}
      </main>
    </div>
  );
};

export function App() {
  return (
    <ThemeProvider>
      <AppContent />
    </ThemeProvider>
  );
}

export default App;
