import { useState } from 'react';
import type { Tool } from '../data/tools';
import { categories, getRelated } from '../data/tools';

interface Props {
  tool: Tool;
  compact?: boolean;
}

const pricingLabel: Record<string, { text: string; color: string }> = {
  'free':        { text: '免费',    color: 'bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-400' },
  'open-source': { text: '开源',    color: 'bg-purple-100 text-purple-700 dark:bg-purple-900/40 dark:text-purple-400' },
  'freemium':    { text: 'Freemium', color: 'bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-400' },
  'paid':        { text: '付费',    color: 'bg-orange-100 text-orange-700 dark:bg-orange-900/40 dark:text-orange-400' },
};

const platformIcon: Record<string, string> = {
  web: '🌐', windows: '🪟', mac: '🍎', linux: '🐧',
  android: '🤖', ios: '📱', chrome: '🌐',
};

export default function ToolCard({ tool, compact = false }: Props) {
  const [copied, setCopied] = useState(false);
  const cat = categories.find(c => c.id === tool.category);
  const pricing = pricingLabel[tool.pricing] || pricingLabel['free'];

  const handleCopy = () => {
    navigator.clipboard.writeText(tool.url).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  };

  return (
    <div className="group relative bg-white dark:bg-gray-800 rounded-2xl border border-gray-100 dark:border-gray-700 shadow-sm hover:shadow-lg hover:border-blue-200 dark:hover:border-blue-700 transition-all duration-300 hover:-translate-y-0.5 flex flex-col overflow-hidden">

      {/* 顶部色条 */}
      <div className={`h-1 w-full ${tool.highlight ? 'bg-gradient-to-r from-blue-500 to-purple-500' : 'bg-gray-100 dark:bg-gray-700'}`} />

      <div className="p-5 flex flex-col flex-1">
        {/* 头部：图标 + 名称 + 分类 */}
        <div className="flex items-start gap-3 mb-3">
          <div className="w-11 h-11 rounded-xl bg-gray-50 dark:bg-gray-700 flex items-center justify-center text-2xl flex-shrink-0 shadow-sm">
            {tool.logo ? (
              <img src={tool.logo} alt={tool.name} className="w-7 h-7 rounded-lg object-contain" />
            ) : (
              <span>{cat?.icon || '🔧'}</span>
            )}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 flex-wrap">
              <a
                href={tool.url}
                target="_blank"
                rel="noopener noreferrer"
                className="font-bold text-gray-900 dark:text-white hover:text-blue-600 dark:hover:text-blue-400 transition-colors truncate text-base leading-tight"
              >
                {tool.name}
              </a>
              {tool.highlight && (
                <span className="px-1.5 py-0.5 text-[10px] font-bold rounded bg-gradient-to-r from-blue-500 to-purple-500 text-white flex-shrink-0">
                  ⭐ 推荐
                </span>
              )}
            </div>
            <div className="flex items-center gap-1.5 mt-1 flex-wrap">
              <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${pricing.color}`}>
                {pricing.text}
              </span>
              {cat && (
                <span className="text-xs text-gray-400 dark:text-gray-500">
                  {cat.icon} {cat.name}
                </span>
              )}
            </div>
          </div>
        </div>

        {/* 描述 */}
        <p className="text-sm text-gray-600 dark:text-gray-300 leading-relaxed flex-1 mb-3 line-clamp-3">
          {tool.description}
        </p>

        {/* 标签 */}
        <div className="flex flex-wrap gap-1.5 mb-3">
          {tool.tags.slice(0, 4).map(tag => (
            <span
              key={tag}
              className="text-xs px-2 py-0.5 rounded-full bg-gray-50 dark:bg-gray-700 text-gray-500 dark:text-gray-400 border border-gray-100 dark:border-gray-600"
            >
              {tag}
            </span>
          ))}
        </div>

        {/* 底部：平台图标 + 操作按钮 */}
        <div className="flex items-center justify-between pt-3 border-t border-gray-50 dark:border-gray-700/50">
          <div className="flex items-center gap-1">
            {tool.platform.map(p => (
              <span key={p} className="text-sm opacity-50" title={p}>
                {platformIcon[p] || '📱'}
              </span>
            ))}
          </div>
          <div className="flex items-center gap-2">
            <a
              href={tool.url}
              target="_blank"
              rel="noopener noreferrer"
              className="px-3 py-1.5 text-sm font-medium rounded-lg bg-blue-600 hover:bg-blue-700 text-white transition-colors shadow-sm"
            >
              访问 →
            </a>
            <button
              onClick={handleCopy}
              title="复制链接"
              className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
            >
              {copied ? '✅' : '📋'}
            </button>
          </div>
        </div>
      </div>

      {/* 推荐替代品标识 */}
      {tool.alternatives && tool.alternatives.length > 0 && (
        <div className="px-5 pb-3 -mt-1">
          <div className="text-xs text-gray-400 dark:text-gray-500">
            替代品: {tool.alternatives.slice(0, 3).join(', ')}
          </div>
        </div>
      )}
    </div>
  );
}
