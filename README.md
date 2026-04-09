# FreeOpen — 免费开源软件导航

> 收录优质免费和开源软件，帮助告别高昂订阅费。

## 🏗 技术栈

| 技术 | 用途 |
|------|------|
| Astro 4 | 静态站点框架（SSG） |
| React 18 | 交互组件（搜索框） |
| TailwindCSS | 样式 |
| Cloudflare Pages | 免费托管 |

## 🚀 本地开发

```bash
# 1. 安装依赖
npm install

# 2. 本地预览
npm run dev
# 访问 http://localhost:4321

# 3. 构建生产版本
npm run build
```

## 📁 项目结构

```
foss-nav/
├── src/
│   ├── components/      # React/ Astro 组件
│   │   ├── SearchBar.tsx    ← 搜索 + 分类筛选（React Island）
│   │   ├── ToolCard.tsx     ← 工具卡片组件
│   │   ├── Header.astro     ← 顶部导航
│   │   └── Footer.astro     ← 底部
│   ├── data/
│   │   └── tools.ts        ← 所有工具数据（JSON，编辑这里即可增删）
│   ├── layouts/
│   │   └── BaseLayout.astro # HTML 基础布局
│   └── pages/
│       ├── index.astro     ← 首页
│       ├── about.astro      ← 关于页
│       └── tool/[id].astro  ← 工具详情页（自动生成）
├── public/                # 静态资源（favicon 等）
├── astro.config.mjs       # Astro 配置
└── package.json
```

## 📝 添加/编辑工具

编辑 `src/data/tools.ts`，按以下格式添加：

```typescript
{
  id: 'unique-id',          // 唯一 ID，英文
  name: '工具名称',           // 中文名
  nameEn: 'Tool Name',      // 英文名
  url: 'https://...',        // 官网地址
  category: 'ai',            // 分类 ID（见 categories）
  tags: ['标签1', '标签2'],   // 标签，3~5 个
  description: '中文描述...',  // 50~100 字
  descriptionEn: 'En desc...',
  pricing: 'free',           // free | open-source | freemium | paid
  platform: ['web', 'windows'], // web | windows | mac | linux | android | ios | chrome
  highlight: true,           // 是否在首页精选推荐
  alternatives: ['id1', 'id2'], // 可选：关联替代品 ID
  addedAt: '2024-01',       // 收录时间
}
```

## ☁️ 部署到 Cloudflare Pages

### 方法一：GitHub 自动部署（推荐）

1. 将项目上传到 GitHub 仓库
2. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com)
3. **Workers & Pages** → **Create Pages Project** → **Connect to Git**
4. 选择仓库，构建设置：
   - **Build command**: `npm run build`
   - **Build output directory**: `dist`
5. 绑定自定义域名

### 方法二：直接上传

1. `npm run build` 构建
2. 上传 `dist/` 文件夹到 Cloudflare Pages

## 🔧 域名解析

新域名接入 Cloudflare 后：
1. Cloudflare 后台 → **Workers & Pages** → 选择项目 → **Custom Domains**
2. 填入新域名 → **Activate Domain**

## 分类 ID 参考

| ID | 分类名 |
|----|--------|
| ai | AI 工具 |
| dev | 开发工具 |
| design | 设计工具 |
| product | 效率工具 |
| media | 多媒体 |
| browser | 浏览器扩展 |
| storage | 云存储 |
| security | 安全隐私 |
| seo | SEO 营销 |
| edu | 教育学习 |

## 📄 License

MIT — 可自由使用、修改、商业化
