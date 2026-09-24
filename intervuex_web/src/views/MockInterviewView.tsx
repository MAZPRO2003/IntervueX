import React, { useState } from 'react';
import { useTheme } from '../context/ThemeContext';
import { Bot, Mic, Send, Award } from 'lucide-react';

export const MockInterviewView: React.FC = () => {
  const { mode, colors } = useTheme();

  const [persona, setPersona] = useState<string>('Strict Technical Lead');
  const [messages, setMessages] = useState<Array<{ sender: 'ai' | 'user'; text: string }>>([
    {
      sender: 'ai',
      text: 'Hello! I am your Technical Interviewer for today. Let us dive right in: Walk me through how you handle connection pooling and transaction rollbacks in your backend architecture.',
    },
  ]);
  const [inputText, setInputText] = useState<string>('');
  const [isRecording, setIsRecording] = useState<boolean>(false);

  const handleSend = () => {
    if (!inputText.trim()) return;

    const newMsgs = [...messages, { sender: 'user' as const, text: inputText }];
    setMessages(newMsgs);
    setInputText('');

    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        {
          sender: 'ai',
          text: 'Great explanation. How would your rollback strategy handle partial failures across distributed microservices where a saga pattern might be needed?',
        },
      ]);
    }, 1000);
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Header */}
      <div className={`p-6 rounded-2xl border flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <div>
          <h1 className="font-heading font-extrabold text-2xl flex items-center gap-2">
            <Bot className="w-6 h-6 text-purple-400" />
            <span>AI Voice & Speech Mock Interviewer</span>
          </h1>
          <p className={`text-xs ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>
            Real-time interactive technical interviewing simulation with instant feedback
          </p>
        </div>

        {/* Persona Switcher */}
        <div className="flex items-center gap-2">
          <label className="text-xs font-bold text-slate-400">Interviewer Persona:</label>
          <select
            value={persona}
            onChange={(e) => setPersona(e.target.value)}
            className={`px-3 py-1.5 rounded-lg border text-xs font-bold outline-none cursor-pointer ${
              mode === 'dark' ? 'bg-[#0B0F19] border-[#334155] text-white' : 'bg-[#F8FAFC] border-[#CBD5E1] text-slate-900'
            }`}
          >
            <option value="Strict Technical Lead">Strict Technical Lead</option>
            <option value="Friendly Senior SDE">Friendly Senior SDE</option>
            <option value="FAANG Bar Raiser">FAANG Bar Raiser</option>
          </select>
        </div>
      </div>

      {/* Main Chamber: Chat & Live Audio Wave */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Chat Chamber */}
        <div className={`lg:col-span-2 p-6 rounded-2xl border flex flex-col justify-between min-h-[480px] ${
          mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
        }`}>
          {/* Transcript Messages */}
          <div className="space-y-4 overflow-y-auto max-h-[380px] pr-2">
            {messages.map((m, idx) => (
              <div
                key={idx}
                className={`flex gap-3 text-xs ${m.sender === 'user' ? 'justify-end' : 'justify-start'}`}
              >
                {m.sender === 'ai' && (
                  <div className="w-8 h-8 rounded-full bg-purple-500/20 text-purple-400 flex items-center justify-center shrink-0 font-bold">
                    AI
                  </div>
                )}

                <div className={`p-3.5 rounded-2xl max-w-lg leading-relaxed ${
                  m.sender === 'user'
                    ? 'text-white'
                    : mode === 'dark'
                    ? 'bg-[#0B0F19] border border-[#1E293B] text-slate-200'
                    : 'bg-[#F8FAFC] border border-[#E2E8F0] text-slate-800'
                }`}
                style={m.sender === 'user' ? { background: colors.gradient } : {}}>
                  <p>{m.text}</p>
                </div>

                {m.sender === 'user' && (
                  <div className="w-8 h-8 rounded-full bg-sky-500/20 text-sky-400 flex items-center justify-center shrink-0 font-bold">
                    You
                  </div>
                )}
              </div>
            ))}
          </div>

          {/* Input Controls */}
          <div className="pt-4 border-t border-slate-500/10 flex items-center gap-2">
            <button
              onClick={() => setIsRecording(!isRecording)}
              className={`p-3 rounded-xl border transition-all ${
                isRecording
                  ? 'bg-rose-500 text-white animate-pulse border-rose-600'
                  : mode === 'dark'
                  ? 'bg-[#0B0F19] border-[#1E293B] text-slate-300 hover:text-white'
                  : 'bg-[#F8FAFC] border-[#CBD5E1] text-slate-700'
              }`}
              title="Voice Mic Input"
            >
              <Mic className="w-5 h-5" />
            </button>

            <input
              type="text"
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSend()}
              placeholder={isRecording ? 'Listening to speech...' : 'Type your answer or speak via mic...'}
              className={`flex-1 px-4 py-3 rounded-xl border text-xs outline-none ${
                mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B] text-white' : 'bg-[#F8FAFC] border-[#CBD5E1] text-slate-900'
              }`}
            />

            <button
              onClick={handleSend}
              className="p-3 rounded-xl text-white shadow-md transition-transform active:scale-95"
              style={{ background: colors.gradient }}
            >
              <Send className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Live Scorecard & Analytics Sidebar */}
        <div className={`p-6 rounded-2xl border space-y-6 ${
          mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
        }`}>
          <h2 className="font-heading font-bold text-lg flex items-center gap-2">
            <Award className="w-5 h-5 text-amber-500" />
            <span>Live Speech Scorecard</span>
          </h2>

          <div className="space-y-4">
            {[
              { label: 'Technical Accuracy', score: 88, color: 'text-emerald-400' },
              { label: 'Communication Clarity', score: 82, color: 'text-sky-400' },
              { label: 'Problem Structure', score: 90, color: 'text-purple-400' },
              { label: 'Confidence & Pace', score: 85, color: 'text-amber-400' },
            ].map((item, idx) => (
              <div key={idx} className="space-y-1">
                <div className="flex justify-between text-xs font-bold">
                  <span>{item.label}</span>
                  <span className={item.color}>{item.score}%</span>
                </div>
                <div className="w-full h-2 rounded-full bg-slate-500/20 overflow-hidden">
                  <div className="h-full rounded-full bg-emerald-500" style={{ width: `${item.score}%` }} />
                </div>
              </div>
            ))}
          </div>

          <div className={`p-4 rounded-xl border text-xs space-y-2 ${
            mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B]' : 'bg-[#F8FAFC] border-[#E2E8F0]'
          }`}>
            <span className="font-bold text-purple-400 block">💡 Live Interview Tip:</span>
            <p className="text-slate-400 leading-relaxed">
              When answering technical architecture questions, structure your answer using the <strong>STAR Method</strong> or outline explicit trade-offs.
            </p>
          </div>
        </div>

      </div>
    </div>
  );
};
