# Metabase local — Compose com Postgres 13

Este ambiente <code>docker compose</code> sobe o **Metabase v0.49.8** conectado a um **PostgreSQL 13 (alpine)** usado como banco de metadados. A ideia é ter uma stack simples para estudos, protótipos ou demonstrações locais, sem depender de serviços externos.
> ⚠️ Ambiente focado em desenvolvimento/lab. Para produção, revise segurança, escalabilidade e backups.

---

## Componentes

- **metabase-db**: container Postgres 13 com volume persistindo os metadados do Metabase
- **metabase**: aplicação Metabase, expondo a UI em http://localhost:5544
- Volumes nomeados: <code>metabase_db_data</code> (Postgres) e <code>metabase_plugins</code> (plugins personalizados)

---

## Pré-requisitos

- Docker + Docker Compose instalados
- Porta **5544** livre no host (ajuste se necessário)
- ~2 GB de RAM disponíveis para subir Metabase com folga

---

## Como usar

~~~bash
docker compose up -d         # sobe Postgres + Metabase
# acompanhe os logs se quiser ver o bootstrap
# docker compose logs -f metabase
~~~

Assim que o container metabase estiver saudável, acesse http://localhost:5544 e siga o assistente inicial para criar o usuário administrador.

Para parar:

~~~bash
docker compose down          # mantém volumes e dados
~~~

---

## Configurações principais

O serviço metabase já vem com as variáveis de ambiente esperadas para uso com o Postgres interno:

- <code>MB_DB_TYPE=postgres</code>
- <code>MB_DB_DBNAME=metabase</code>
- <code>MB_DB_HOST=metabase-db</code>
- <code>MB_DB_PORT=5432</code>
- <code>MB_DB_USER=metabase</code>
- <code>MB_DB_PASS=metabase</code>
- <code>MB_SITE_URL=http://localhost:5544</code>
- <code>MB_JETTY_HOST=0.0.0.0</code>
- <code>MB_JETTY_PORT=5544</code>

Sinta-se à vontade para alterar usuário/senha do banco ou expor a aplicação em outra porta (ajuste <code>MB_JETTY_PORT</code> e o bloco <code>ports</code>).

---

## Persistência & plugins

- **Banco**: os metadados ficam em <code>metabase_db_data</code>. Faça backup antes de remover o volume.
- **Plugins**: monte plugins customizados em <code>metabase_plugins</code> (pasta <code>/plugins</code> dentro do container Metabase). Coloque arquivos .jar ali para habilitar drivers adicionais.

---

## Atualizar versões

1. Edite a imagem do Postgres (postgres:13-alpine) ou do Metabase (metabase/metabase:v0.49.8) no docker-compose.yml.
2. Rode <code>docker compose pull</code> para baixar as novas imagens.
3. Reinicie a stack (<code>docker compose up -d</code>).
4. Verifique os logs antes de aplicar em ambientes com dados importantes.

---

## Limpar tudo

~~~bash
docker compose down -v      # remove containers e volumes (apaga metadados/plugins)
~~~

---

## Recursos úteis

- Documentação oficial do Metabase: https://www.metabase.com/docs/latest/
- Configurações via variáveis de ambiente: https://www.metabase.com/docs/latest/operations-guide/environment-variables.html
- Drivers e plugins suportados: https://www.metabase.com/docs/latest/administration-guide/01-managing-database-connections.html





------------------------

import React, { useState, useEffect } from "react";
import {
  Shield,
  Lock,
  Terminal,
  AlertTriangle,
  CheckCircle,
  XCircle,
  Cpu,
  Activity,
  Eye,
  EyeOff,
  Wifi,
  Server,
  HardDrive,
  Zap,
  Code,
  Database,
  X,
  ChevronDown,
  TrendingUp,
  TrendingDown,
  ChevronRight,
  Home,
  Bell,
  Info,
  Menu,
  User,
  Settings,
  LogOut,
  Search,
  Filter,
  MoreVertical,
  Upload,
  GripVertical,
  Copy,
  Check,
} from "lucide-react";

// ==================== AVATAR COMPONENT ====================
const Avatar = ({ src, name, size = "md", status, tooltip }) => {
  const sizes = {
    sm: "w-8 h-8 text-xs",
    md: "w-12 h-12 text-sm",
    lg: "w-16 h-16 text-base",
    xl: "w-24 h-24 text-xl",
  };

  const statusColors = {
    online: "bg-green-400",
    offline: "bg-gray-600",
    busy: "bg-red-400",
    away: "bg-yellow-400",
  };

  const initials =
    name
      ?.split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase() || "?";

  const avatar = (
    <div className="relative inline-block">
      <div
        className={`${sizes[size]} rounded-full border-2 border-cyan-400 overflow-hidden bg-gray-900 flex items-center justify-center font-mono font-bold text-cyan-400`}
      >
        {src ? <img src={src} alt={name} className="w-full h-full object-cover" /> : <span>{initials}</span>}
      </div>
      {status && (
        <div
          className={`absolute bottom-0 right-0 w-3 h-3 rounded-full border-2 border-black ${statusColors[status]}`}
        />
      )}
    </div>
  );

  return tooltip ? <Tooltip content={tooltip}>{avatar}</Tooltip> : avatar;
};

// ==================== TOOLBAR COMPONENT ====================
const Toolbar = ({ children, position = "top" }) => {
  const positions = {
    top: "top-0 left-0 right-0 border-b-2",
    bottom: "bottom-0 left-0 right-0 border-t-2",
  };

  return (
    <div
      className={`${positions[position]} bg-gray-950 border-cyan-500 px-4 py-3 flex items-center justify-between gap-4`}
    >
      {children}
    </div>
  );
};

// ==================== DRAG AND DROP COMPONENT ====================
const DragDropZone = ({ onDrop, accept = "*" }) => {
  const [isDragging, setIsDragging] = useState(false);
  const [files, setFiles] = useState([]);

  const handleDragOver = (e) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setIsDragging(false);
    const droppedFiles = Array.from(e.dataTransfer.files);
    setFiles((prev) => [...prev, ...droppedFiles]);
    onDrop?.(droppedFiles);
  };

  const handleFileInput = (e) => {
    const selectedFiles = Array.from(e.target.files);
    setFiles((prev) => [...prev, ...selectedFiles]);
    onDrop?.(selectedFiles);
  };

  const removeFile = (index) => {
    setFiles((prev) => prev.filter((_, i) => i !== index));
  };

  return (
    <div className="space-y-4">
      <div
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
        className={`border-2 border-dashed rounded-lg p-8 text-center transition-all ${
          isDragging ? "border-cyan-400 bg-cyan-400/10 scale-105" : "border-gray-700 hover:border-cyan-500"
        }`}
      >
        <Upload className="mx-auto mb-4 text-cyan-400" size={48} />
        <p className="text-cyan-400 font-mono font-bold mb-2">
          {isDragging ? "SOLTE OS ARQUIVOS AQUI" : "ARRASTE ARQUIVOS AQUI"}
        </p>
        <p className="text-gray-500 font-mono text-xs mb-4">ou clique para selecionar</p>
        <input type="file" multiple accept={accept} onChange={handleFileInput} className="hidden" id="file-input" />
        <label htmlFor="file-input">
          <span className="inline-block px-4 py-2 bg-cyan-500 text-black font-mono font-bold rounded cursor-pointer hover:bg-cyan-600 transition-colors">
            SELECIONAR ARQUIVOS
          </span>
        </label>
      </div>

      {files.length > 0 && (
        <div className="space-y-2">
          {files.map((file, idx) => (
            <div
              key={idx}
              className="flex items-center justify-between bg-gray-950 border border-cyan-500 rounded px-4 py-2"
            >
              <span className="text-green-400 font-mono text-sm">{file.name}</span>
              <button onClick={() => removeFile(idx)} className="text-red-400 hover:text-red-300">
                <X size={16} />
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

// ==================== SKELETON LOADER COMPONENT ====================
const Skeleton = ({ variant = "text", width, height, className = "" }) => {
  const variants = {
    text: "h-4 rounded",
    circle: "rounded-full",
    rect: "rounded",
    card: "h-48 rounded-lg",
  };

  return <div className={`bg-gray-800 animate-pulse ${variants[variant]} ${className}`} style={{ width, height }} />;
};

// ==================== SIDE NAVIGATION COMPONENT ====================
const SideNav = ({ items, isOpen, onClose }) => {
  return (
    <>
      {isOpen && <div className="fixed inset-0 bg-black/80 z-40 lg:hidden" onClick={onClose} />}

      <div
        className={`
        fixed top-0 left-0 h-full w-64 bg-gray-950 border-r-2 border-cyan-500 z-50
        transform transition-transform duration-300 lg:translate-x-0
        ${isOpen ? "translate-x-0" : "-translate-x-full"}
      `}
      >
        <div className="p-4 border-b-2 border-cyan-500 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Shield className="text-cyan-400" size={24} />
            <span className="text-cyan-400 font-mono font-bold">CYBERUI</span>
          </div>
          <button onClick={onClose} className="lg:hidden text-cyan-400">
            <X size={20} />
          </button>
        </div>

        <nav className="p-4 space-y-2">
          {items.map((item, idx) => (
            <a
              key={idx}
              href={item.href}
              className={`
                flex items-center gap-3 px-4 py-3 rounded font-mono text-sm
                transition-colors
                ${item.active ? "bg-cyan-500 text-black font-bold" : "text-cyan-400 hover:bg-cyan-400/10"}
              `}
            >
              {item.icon && <item.icon size={18} />}
              <span>{item.label}</span>
              {item.badge && (
                <span className="ml-auto bg-red-500 text-white text-xs px-2 py-0.5 rounded-full">{item.badge}</span>
              )}
            </a>
          ))}
        </nav>
      </div>
    </>
  );
};

// ==================== CARD COMPONENT ====================
const CyberCard = ({ title, subtitle, image, children, actions, hoverable = true }) => {
  return (
    <div
      className={`
      bg-gray-950 border-2 border-gray-700 rounded-lg overflow-hidden
      transition-all duration-300
      ${hoverable ? "hover:border-cyan-400 hover:shadow-lg hover:shadow-cyan-400/20 hover:-translate-y-1" : ""}
    `}
    >
      {image && (
        <div className="relative h-48 bg-gray-900 overflow-hidden">
          <img src={image} alt={title} className="w-full h-full object-cover" />
          <div className="absolute inset-0 bg-gradient-to-t from-gray-950 to-transparent" />
        </div>
      )}

      <div className="p-4 space-y-3">
        {(title || subtitle) && (
          <div>
            {title && <h3 className="text-cyan-400 font-mono font-bold">{title}</h3>}
            {subtitle && <p className="text-gray-500 font-mono text-xs mt-1">{subtitle}</p>}
          </div>
        )}

        {children && <div className="text-gray-400 font-mono text-sm">{children}</div>}

        {actions && <div className="flex gap-2 pt-2">{actions}</div>}
      </div>
    </div>
  );
};

// ==================== GRID COMPONENT ====================
const Grid = ({ children, cols = 3, gap = 4 }) => {
  const colClasses = {
    1: "grid-cols-1",
    2: "grid-cols-1 md:grid-cols-2",
    3: "grid-cols-1 md:grid-cols-2 lg:grid-cols-3",
    4: "grid-cols-1 md:grid-cols-2 lg:grid-cols-4",
  };

  const gapClasses = {
    2: "gap-2",
    4: "gap-4",
    6: "gap-6",
    8: "gap-8",
  };

  return <div className={`grid ${colClasses[cols]} ${gapClasses[gap]}`}>{children}</div>;
};

// ==================== TOOLTIP COMPONENT ====================
const Tooltip = ({ children, content, position = "top" }) => {
  const [show, setShow] = useState(false);
  const positions = {
    top: "bottom-full left-1/2 -translate-x-1/2 mb-2",
    bottom: "top-full left-1/2 -translate-x-1/2 mt-2",
    left: "right-full top-1/2 -translate-y-1/2 mr-2",
    right: "left-full top-1/2 -translate-y-1/2 ml-2",
  };

  return (
    <div className="relative inline-block" onMouseEnter={() => setShow(true)} onMouseLeave={() => setShow(false)}>
      {children}
      {show && (
        <div className={`absolute z-50 ${positions[position]} whitespace-nowrap`}>
          <div className="bg-gray-900 border-2 border-cyan-400 rounded px-3 py-2 text-xs font-mono text-cyan-400 shadow-lg">
            {content}
          </div>
        </div>
      )}
    </div>
  );
};

// ==================== BUTTON COMPONENT ====================
const GlitchButton = ({ children, onClick, variant = "primary", disabled = false, size = "md" }) => {
  const [glitch, setGlitch] = useState(false);

  const variants = {
    primary: "bg-cyan-500 hover:bg-cyan-600 text-black border-cyan-500",
    danger: "bg-red-500 hover:bg-red-600 text-white border-red-500",
    success: "bg-green-500 hover:bg-green-600 text-black border-green-500",
    ghost: "bg-transparent border-cyan-400 text-cyan-400 hover:bg-cyan-400/10",
  };

  const sizes = {
    sm: "px-3 py-1 text-xs",
    md: "px-6 py-2 text-sm",
    lg: "px-8 py-3 text-base",
  };

  const handleClick = (e) => {
    if (disabled) return;
    setGlitch(true);
    setTimeout(() => setGlitch(false), 200);
    onClick?.(e);
  };

  return (
    <button
      onClick={handleClick}
      disabled={disabled}
      className={`
        ${variants[variant]}
        ${sizes[size]}
        font-mono font-bold uppercase tracking-wider
        border-2 rounded transition-all duration-150
        ${glitch ? "scale-95 opacity-80" : "scale-100"}
        ${disabled ? "opacity-50 cursor-not-allowed" : "hover:shadow-lg"}
      `}
    >
      {children}
    </button>
  );
};

// ==================== CODE BLOCK COMPONENT ====================
const CodeBlock = ({ code, language = "javascript", title }) => {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="bg-gray-900 rounded-lg border-2 border-gray-700 overflow-hidden">
      <div className="bg-gray-950 px-4 py-2 border-b-2 border-gray-700 flex items-center justify-between">
        <span className="text-cyan-400 font-mono text-xs">{title || `${language}.code`}</span>
        <button
          onClick={handleCopy}
          className="text-gray-600 hover:text-cyan-400 transition-colors flex items-center gap-1"
        >
          {copied ? <Check size={14} /> : <Copy size={14} />}
          <span className="text-xs">{copied ? "Copiado!" : "Copiar"}</span>
        </button>
      </div>
      <pre className="p-4 overflow-x-auto">
        <code className="text-green-400 font-mono text-sm whitespace-pre">{code}</code>
      </pre>
    </div>
  );
};

// ==================== PANEL COMPONENT ====================
const CyberPanel = ({ title, icon: Icon, children, highlight = false }) => {
  return (
    <div
      className={`
      bg-gray-950 border-2 rounded-lg overflow-hidden
      ${highlight ? "border-cyan-400 shadow-lg shadow-cyan-400/20" : "border-gray-700"}
    `}
    >
      <div className="bg-gradient-to-r from-gray-900 to-gray-800 px-4 py-3 border-b-2 border-current">
        <div className="flex items-center gap-2 font-mono">
          {Icon && <Icon size={18} className="text-cyan-400" />}
          <span className="text-cyan-400 font-bold">{title}</span>
        </div>
      </div>
      <div className="p-4">{children}</div>
    </div>
  );
};

// ==================== DEMO APP ====================
export default function ComponentLibrary() {
  const [copied, setCopied] = useState("");

  const copyCode = (componentName, code) => {
    navigator.clipboard.writeText(code);
    setCopied(componentName);
    setTimeout(() => setCopied(""), 2000);
  };

  const avatarCode = `<Avatar 
  name="John Doe" 
  size="md" 
  status="online" 
  tooltip="John Doe - Online"
/>`;

  const toolbarCode = `<Toolbar position="top">
  <div className="flex items-center gap-4">
    <Shield className="text-cyan-400" size={24} />
    <span className="text-cyan-400 font-mono font-bold">TITLE</span>
  </div>
  <div className="flex items-center gap-4">
    {/* Actions */}
  </div>
</Toolbar>`;

  const cardCode = `<CyberCard
  title="Card Title"
  subtitle="Card Subtitle"
  hoverable={true}
  actions={
    <>
      <GlitchButton size="sm" variant="primary">ACTION</GlitchButton>
    </>
  }
>
  <p>Card content here</p>
</CyberCard>`;

  const buttonCode = `<GlitchButton 
  variant="primary" 
  size="md"
  onClick={() => alert('Clicked!')}
>
  CLICK ME
</GlitchButton>`;

  const dragDropCode = `<DragDropZone 
  onDrop={(files) => console.log(files)}
  accept="image/*"
/>`;

  const gridCode = `<Grid cols={3} gap={4}>
  <CyberCard title="Card 1" />
  <CyberCard title="Card 2" />
  <CyberCard title="Card 3" />
</Grid>`;

  return (
    <div className="min-h-screen bg-black p-8">
      <div className="max-w-7xl mx-auto space-y-8">
        {/* Header */}
        <div className="text-center space-y-4 py-12">
          <div className="flex items-center justify-center gap-3 mb-4">
            <Shield className="text-cyan-400" size={48} />
            <h1 className="text-5xl font-bold text-cyan-400 font-mono">CYBERSEC UI</h1>
          </div>
          <p className="text-gray-500 font-mono text-lg">Biblioteca de Componentes React - Tema Cyberpunk</p>
          <div className="flex items-center justify-center gap-4 mt-6">
            <div className="flex items-center gap-2 px-4 py-2 bg-gray-950 border border-cyan-500 rounded">
              <Code className="text-cyan-400" size={16} />
              <span className="text-cyan-400 font-mono text-sm">React 18+</span>
            </div>
            <div className="flex items-center gap-2 px-4 py-2 bg-gray-950 border border-green-500 rounded">
              <CheckCircle className="text-green-400" size={16} />
              <span className="text-green-400 font-mono text-sm">Tailwind CSS</span>
            </div>
            <div className="flex items-center gap-2 px-4 py-2 bg-gray-950 border border-yellow-500 rounded">
              <Zap className="text-yellow-400" size={16} />
              <span className="text-yellow-400 font-mono text-sm">Lucide Icons</span>
            </div>
          </div>
        </div>

        {/* Avatar Component */}
        <CyberPanel title="AVATAR COMPONENT" icon={User} highlight>
          <div className="space-y-6">
            <p className="text-gray-400 font-mono text-sm">Avatar com status indicators e tooltips.</p>

            <div className="flex flex-wrap items-center gap-6 p-6 bg-gray-900 rounded-lg border border-gray-800">
              <Avatar name="John Doe" size="sm" status="online" />
              <Avatar name="Jane Smith" size="md" status="busy" />
              <Avatar name="Bob Wilson" size="lg" status="away" />
              <Avatar name="Alice Johnson" size="xl" status="offline" />
            </div>

            <CodeBlock code={avatarCode} language="jsx" title="Avatar.jsx" />

            <div className="space-y-2">
              <h4 className="text-cyan-400 font-mono font-bold text-sm">PROPS:</h4>
              <div className="bg-gray-900 rounded p-4 font-mono text-xs space-y-1">
                <p className="text-gray-400">
                  <span className="text-green-400">name</span>: string - Nome do usuário
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">size</span>: 'sm' | 'md' | 'lg' | 'xl' - Tamanho do avatar
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">status</span>: 'online' | 'offline' | 'busy' | 'away' - Status
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">src</span>: string - URL da imagem (opcional)
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">tooltip</span>: string - Texto do tooltip (opcional)
                </p>
              </div>
            </div>
          </div>
        </CyberPanel>

        {/* Button Component */}
        <CyberPanel title="GLITCH BUTTON" icon={Zap}>
          <div className="space-y-6">
            <p className="text-gray-400 font-mono text-sm">Botões com efeito glitch e múltiplas variantes.</p>

            <div className="flex flex-wrap items-center gap-4 p-6 bg-gray-900 rounded-lg border border-gray-800">
              <GlitchButton variant="primary" size="sm">
                SMALL
              </GlitchButton>
              <GlitchButton variant="primary" size="md">
                MEDIUM
              </GlitchButton>
              <GlitchButton variant="primary" size="lg">
                LARGE
              </GlitchButton>
              <GlitchButton variant="danger">DANGER</GlitchButton>
              <GlitchButton variant="success">SUCCESS</GlitchButton>
              <GlitchButton variant="ghost">GHOST</GlitchButton>
              <GlitchButton disabled>DISABLED</GlitchButton>
            </div>

            <CodeBlock code={buttonCode} language="jsx" title="Button.jsx" />

            <div className="space-y-2">
              <h4 className="text-cyan-400 font-mono font-bold text-sm">PROPS:</h4>
              <div className="bg-gray-900 rounded p-4 font-mono text-xs space-y-1">
                <p className="text-gray-400">
                  <span className="text-green-400">variant</span>: 'primary' | 'danger' | 'success' | 'ghost'
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">size</span>: 'sm' | 'md' | 'lg'
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">disabled</span>: boolean
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">onClick</span>: function
                </p>
              </div>
            </div>
          </div>
        </CyberPanel>

        {/* Card Component */}
        <CyberPanel title="CYBER CARD" icon={Database}>
          <div className="space-y-6">
            <p className="text-gray-400 font-mono text-sm">Cards com hover effects e actions.</p>

            <Grid cols={3} gap={4}>
              <CyberCard
                title="Sistema de Firewall"
                subtitle="Proteção em Tempo Real"
                hoverable={true}
                actions={
                  <>
                    <GlitchButton size="sm" variant="primary">
                      ATIVAR
                    </GlitchButton>
                    <GlitchButton size="sm" variant="ghost">
                      INFO
                    </GlitchButton>
                  </>
                }
              >
                <p>Monitoramento ativo de conexões</p>
              </CyberCard>

              <CyberCard title="Análise de Ameaças" subtitle="AI-Powered" hoverable={true}>
                <p>47 ameaças bloqueadas hoje</p>
              </CyberCard>

              <CyberCard title="Backup Automático" subtitle="Cloud Storage" hoverable={true}>
                <p>Último backup: 2 horas atrás</p>
              </CyberCard>
            </Grid>

            <CodeBlock code={cardCode} language="jsx" title="Card.jsx" />

            <div className="space-y-2">
              <h4 className="text-cyan-400 font-mono font-bold text-sm">PROPS:</h4>
              <div className="bg-gray-900 rounded p-4 font-mono text-xs space-y-1">
                <p className="text-gray-400">
                  <span className="text-green-400">title</span>: string - Título do card
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">subtitle</span>: string - Subtítulo (opcional)
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">image</span>: string - URL da imagem (opcional)
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">hoverable</span>: boolean - Efeito hover
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">actions</span>: ReactNode - Botões de ação
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">children</span>: ReactNode - Conteúdo
                </p>
              </div>
            </div>
          </div>
        </CyberPanel>

        {/* Grid Component */}
        <CyberPanel title="GRID SYSTEM" icon={Activity}>
          <div className="space-y-6">
            <p className="text-gray-400 font-mono text-sm">Sistema de grid responsivo.</p>

            <div className="space-y-6">
              <div>
                <h4 className="text-green-400 font-mono text-sm mb-3">2 COLUNAS</h4>
                <Grid cols={2} gap={4}>
                  <div className="bg-gray-900 border border-cyan-500 rounded p-4 text-center">
                    <p className="text-cyan-400 font-mono">Grid Item 1</p>
                  </div>
                  <div className="bg-gray-900 border border-cyan-500 rounded p-4 text-center">
                    <p className="text-cyan-400 font-mono">Grid Item 2</p>
                  </div>
                </Grid>
              </div>

              <div>
                <h4 className="text-green-400 font-mono text-sm mb-3">4 COLUNAS</h4>
                <Grid cols={4} gap={4}>
                  {[1, 2, 3, 4].map((i) => (
                    <div key={i} className="bg-gray-900 border border-cyan-500 rounded p-4 text-center">
                      <p className="text-cyan-400 font-mono">Item {i}</p>
                    </div>
                  ))}
                </Grid>
              </div>
            </div>

            <CodeBlock code={gridCode} language="jsx" title="Grid.jsx" />

            <div className="space-y-2">
              <h4 className="text-cyan-400 font-mono font-bold text-sm">PROPS:</h4>
              <div className="bg-gray-900 rounded p-4 font-mono text-xs space-y-1">
                <p className="text-gray-400">
                  <span className="text-green-400">cols</span>: 1 | 2 | 3 | 4 - Número de colunas
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">gap</span>: 2 | 4 | 6 | 8 - Espaçamento
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">children</span>: ReactNode - Itens do grid
                </p>
              </div>
            </div>
          </div>
        </CyberPanel>

        {/* Drag Drop Component */}
        <CyberPanel title="DRAG & DROP ZONE" icon={Upload}>
          <div className="space-y-6">
            <p className="text-gray-400 font-mono text-sm">Zona de upload com drag and drop.</p>

            <DragDropZone onDrop={(files) => console.log("Arquivos:", files)} accept="*" />

            <CodeBlock code={dragDropCode} language="jsx" title="DragDrop.jsx" />

            <div className="space-y-2">
              <h4 className="text-cyan-400 font-mono font-bold text-sm">PROPS:</h4>
              <div className="bg-gray-900 rounded p-4 font-mono text-xs space-y-1">
                <p className="text-gray-400">
                  <span className="text-green-400">onDrop</span>: function - Callback com arquivos
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">accept</span>: string - Tipos de arquivo aceitos
                </p>
              </div>
            </div>
          </div>
        </CyberPanel>

        {/* Skeleton Component */}
        <CyberPanel title="SKELETON LOADER" icon={Cpu}>
          <div className="space-y-6">
            <p className="text-gray-400 font-mono text-sm">Loading placeholders animados.</p>

            <div className="space-y-4 p-6 bg-gray-900 rounded-lg border border-gray-800">
              <div className="flex items-center gap-4">
                <Skeleton variant="circle" width="48px" height="48px" />
                <div className="flex-1 space-y-2">
                  <Skeleton variant="text" width="60%" />
                  <Skeleton variant="text" width="40%" />
                </div>
              </div>
              <Skeleton variant="card" />
              <div className="space-y-2">
                <Skeleton variant="text" width="100%" />
                <Skeleton variant="text" width="85%" />
              </div>
            </div>

            <CodeBlock
              code={`<Skeleton variant="text" width="60%" />
<Skeleton variant="circle" width="48px" height="48px" />
<Skeleton variant="card" />
<Skeleton variant="rect" width="200px" height="100px" />`}
              language="jsx"
              title="Skeleton.jsx"
            />

            <div className="space-y-2">
              <h4 className="text-cyan-400 font-mono font-bold text-sm">PROPS:</h4>
              <div className="bg-gray-900 rounded p-4 font-mono text-xs space-y-1">
                <p className="text-gray-400">
                  <span className="text-green-400">variant</span>: 'text' | 'circle' | 'rect' | 'card'
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">width</span>: string - Largura (ex: '60%', '200px')
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">height</span>: string - Altura (opcional)
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">className</span>: string - Classes adicionais
                </p>
              </div>
            </div>
          </div>
        </CyberPanel>

        {/* Toolbar Component */}
        <CyberPanel title="TOOLBAR COMPONENT" icon={Settings}>
          <div className="space-y-6">
            <p className="text-gray-400 font-mono text-sm">Barra de ferramentas responsiva.</p>

            <div className="space-y-4">
              <Toolbar position="top">
                <div className="flex items-center gap-4">
                  <Shield className="text-cyan-400" size={24} />
                  <span className="text-cyan-400 font-mono font-bold">TOP TOOLBAR</span>
                </div>
                <div className="flex items-center gap-4">
                  <button className="text-cyan-400 hover:text-cyan-300">
                    <Search size={20} />
                  </button>
                  <button className="text-cyan-400 hover:text-cyan-300">
                    <Bell size={20} />
                  </button>
                </div>
              </Toolbar>

              <div className="h-32 bg-gray-900 border border-gray-700 rounded flex items-center justify-center">
                <p className="text-gray-500 font-mono text-sm">Conteúdo da página</p>
              </div>
            </div>

            <CodeBlock code={toolbarCode} language="jsx" title="Toolbar.jsx" />

            <div className="space-y-2">
              <h4 className="text-cyan-400 font-mono font-bold text-sm">PROPS:</h4>
              <div className="bg-gray-900 rounded p-4 font-mono text-xs space-y-1">
                <p className="text-gray-400">
                  <span className="text-green-400">position</span>: 'top' | 'bottom' - Posição da toolbar
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">children</span>: ReactNode - Conteúdo da toolbar
                </p>
              </div>
            </div>
          </div>
        </CyberPanel>

        {/* Panel Component */}
        <CyberPanel title="CYBER PANEL" icon={Terminal}>
          <div className="space-y-6">
            <p className="text-gray-400 font-mono text-sm">Container com header estilizado.</p>

            <div className="space-y-4">
              <CyberPanel title="PANEL NORMAL" icon={Code}>
                <p className="text-gray-400 font-mono text-sm">Conteúdo do panel normal</p>
              </CyberPanel>

              <CyberPanel title="PANEL DESTACADO" icon={Zap} highlight>
                <p className="text-gray-400 font-mono text-sm">Conteúdo do panel com destaque</p>
              </CyberPanel>
            </div>

            <CodeBlock
              code={`<CyberPanel title="TITLE" icon={IconComponent} highlight={true}>
  <p>Conteúdo aqui</p>
</CyberPanel>`}
              language="jsx"
              title="Panel.jsx"
            />

            <div className="space-y-2">
              <h4 className="text-cyan-400 font-mono font-bold text-sm">PROPS:</h4>
              <div className="bg-gray-900 rounded p-4 font-mono text-xs space-y-1">
                <p className="text-gray-400">
                  <span className="text-green-400">title</span>: string - Título do panel
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">icon</span>: LucideIcon - Ícone (opcional)
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">highlight</span>: boolean - Destaque com borda cyan
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">children</span>: ReactNode - Conteúdo
                </p>
              </div>
            </div>
          </div>
        </CyberPanel>

        {/* Code Block Component */}
        <CyberPanel title="CODE BLOCK" icon={Code}>
          <div className="space-y-6">
            <p className="text-gray-400 font-mono text-sm">Exibição de código com botão de copiar.</p>

            <CodeBlock
              code={`const hello = () => {
  console.log('Hello World!');
  return 'CyberSec UI';
};

hello();`}
              language="javascript"
              title="example.js"
            />

            <CodeBlock
              code={`<CodeBlock 
  code={yourCodeString}
  language="javascript"
  title="filename.js"
/>`}
              language="jsx"
              title="Usage.jsx"
            />

            <div className="space-y-2">
              <h4 className="text-cyan-400 font-mono font-bold text-sm">PROPS:</h4>
              <div className="bg-gray-900 rounded p-4 font-mono text-xs space-y-1">
                <p className="text-gray-400">
                  <span className="text-green-400">code</span>: string - Código a ser exibido
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">language</span>: string - Linguagem (ex: 'javascript')
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">title</span>: string - Nome do arquivo (opcional)
                </p>
              </div>
            </div>
          </div>
        </CyberPanel>

        {/* Tooltip Component */}
        <CyberPanel title="TOOLTIP COMPONENT" icon={Info}>
          <div className="space-y-6">
            <p className="text-gray-400 font-mono text-sm">Tooltips informativos com posicionamento.</p>

            <div className="flex flex-wrap items-center justify-center gap-12 p-12 bg-gray-900 rounded-lg border border-gray-800">
              <Tooltip content="Tooltip no topo" position="top">
                <GlitchButton size="sm" variant="ghost">
                  TOP
                </GlitchButton>
              </Tooltip>

              <Tooltip content="Tooltip à direita" position="right">
                <GlitchButton size="sm" variant="ghost">
                  RIGHT
                </GlitchButton>
              </Tooltip>

              <Tooltip content="Tooltip embaixo" position="bottom">
                <GlitchButton size="sm" variant="ghost">
                  BOTTOM
                </GlitchButton>
              </Tooltip>

              <Tooltip content="Tooltip à esquerda" position="left">
                <GlitchButton size="sm" variant="ghost">
                  LEFT
                </GlitchButton>
              </Tooltip>
            </div>

            <CodeBlock
              code={`<Tooltip content="Informação" position="top">
  <button>Hover me</button>
</Tooltip>`}
              language="jsx"
              title="Tooltip.jsx"
            />

            <div className="space-y-2">
              <h4 className="text-cyan-400 font-mono font-bold text-sm">PROPS:</h4>
              <div className="bg-gray-900 rounded p-4 font-mono text-xs space-y-1">
                <p className="text-gray-400">
                  <span className="text-green-400">content</span>: string - Texto do tooltip
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">position</span>: 'top' | 'right' | 'bottom' | 'left'
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">children</span>: ReactNode - Elemento trigger
                </p>
              </div>
            </div>
          </div>
        </CyberPanel>

        {/* Side Navigation Component */}
        <CyberPanel title="SIDE NAVIGATION" icon={Menu}>
          <div className="space-y-6">
            <p className="text-gray-400 font-mono text-sm">Menu lateral responsivo com overlay mobile.</p>

            <div className="bg-gray-900 rounded-lg border border-gray-800 p-4">
              <p className="text-yellow-400 font-mono text-sm mb-3">
                ⚠️ Componente de layout - Veja o código de uso abaixo
              </p>
              <div className="space-y-2 text-gray-400 font-mono text-xs">
                <p>• Menu lateral fixo</p>
                <p>• Responsivo com overlay mobile</p>
                <p>• Suporte a ícones e badges</p>
                <p>• Estado ativo nos items</p>
              </div>
            </div>

            <CodeBlock
              code={`const [navOpen, setNavOpen] = useState(false);

const items = [
  { icon: Home, label: 'Dashboard', href: '#', active: true },
  { icon: Shield, label: 'Security', href: '#', badge: '3' },
  { icon: Server, label: 'Servers', href: '#' },
  { icon: Settings, label: 'Settings', href: '#' }
];

<SideNav 
  items={items} 
  isOpen={navOpen} 
  onClose={() => setNavOpen(false)} 
/>`}
              language="jsx"
              title="SideNav.jsx"
            />

            <div className="space-y-2">
              <h4 className="text-cyan-400 font-mono font-bold text-sm">PROPS:</h4>
              <div className="bg-gray-900 rounded p-4 font-mono text-xs space-y-1">
                <p className="text-gray-400">
                  <span className="text-green-400">items</span>: Array - Lista de items do menu
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">isOpen</span>: boolean - Estado de abertura (mobile)
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">onClose</span>: function - Callback para fechar
                </p>
              </div>
              <div className="bg-gray-900 rounded p-4 font-mono text-xs space-y-1 mt-3">
                <p className="text-cyan-400 font-bold">Item Object:</p>
                <p className="text-gray-400">
                  <span className="text-green-400">icon</span>: LucideIcon - Ícone do item
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">label</span>: string - Texto do item
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">href</span>: string - Link de navegação
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">active</span>: boolean - Item ativo (opcional)
                </p>
                <p className="text-gray-400">
                  <span className="text-green-400">badge</span>: string - Badge de notificação (opcional)
                </p>
              </div>
            </div>
          </div>
        </CyberPanel>

        {/* Color Palette */}
        <CyberPanel title="COLOR PALETTE" icon={Activity} highlight>
          <div className="space-y-6">
            <p className="text-gray-400 font-mono text-sm">Paleta de cores do tema cyberpunk.</p>

            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="space-y-2">
                <div className="h-24 bg-cyan-400 rounded-lg border-2 border-cyan-400" />
                <p className="text-cyan-400 font-mono text-xs font-bold">CYAN-400</p>
                <p className="text-gray-500 font-mono text-xs">#22D3EE</p>
              </div>

              <div className="space-y-2">
                <div className="h-24 bg-cyan-500 rounded-lg border-2 border-cyan-500" />
                <p className="text-cyan-500 font-mono text-xs font-bold">CYAN-500</p>
                <p className="text-gray-500 font-mono text-xs">#06B6D4</p>
              </div>

              <div className="space-y-2">
                <div className="h-24 bg-green-400 rounded-lg border-2 border-green-400" />
                <p className="text-green-400 font-mono text-xs font-bold">GREEN-400</p>
                <p className="text-gray-500 font-mono text-xs">#4ADE80</p>
              </div>

              <div className="space-y-2">
                <div className="h-24 bg-red-400 rounded-lg border-2 border-red-400" />
                <p className="text-red-400 font-mono text-xs font-bold">RED-400</p>
                <p className="text-gray-500 font-mono text-xs">#F87171</p>
              </div>

              <div className="space-y-2">
                <div className="h-24 bg-yellow-400 rounded-lg border-2 border-yellow-400" />
                <p className="text-yellow-400 font-mono text-xs font-bold">YELLOW-400</p>
                <p className="text-gray-500 font-mono text-xs">#FACC15</p>
              </div>

              <div className="space-y-2">
                <div className="h-24 bg-gray-950 rounded-lg border-2 border-gray-700" />
                <p className="text-gray-400 font-mono text-xs font-bold">GRAY-950</p>
                <p className="text-gray-500 font-mono text-xs">#030712</p>
              </div>

              <div className="space-y-2">
                <div className="h-24 bg-gray-900 rounded-lg border-2 border-gray-700" />
                <p className="text-gray-400 font-mono text-xs font-bold">GRAY-900</p>
                <p className="text-gray-500 font-mono text-xs">#111827</p>
              </div>

              <div className="space-y-2">
                <div className="h-24 bg-gray-800 rounded-lg border-2 border-gray-700" />
                <p className="text-gray-400 font-mono text-xs font-bold">GRAY-800</p>
                <p className="text-gray-500 font-mono text-xs">#1F2937</p>
              </div>
            </div>
          </div>
        </CyberPanel>

        {/* Installation Guide */}
        <CyberPanel title="INSTALAÇÃO E USO" icon={Terminal} highlight>
          <div className="space-y-6">
            <div>
              <h4 className="text-cyan-400 font-mono font-bold text-sm mb-3">1. DEPENDÊNCIAS</h4>
              <CodeBlock
                code={`npm install react lucide-react
# ou
yarn add react lucide-react`}
                language="bash"
                title="terminal"
              />
            </div>

            <div>
              <h4 className="text-cyan-400 font-mono font-bold text-sm mb-3">2. TAILWIND CONFIG</h4>
              <CodeBlock
                code={`// tailwind.config.js
module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      fontFamily: {
        mono: ['Courier New', 'monospace'],
      }
    }
  }
}`}
                language="javascript"
                title="tailwind.config.js"
              />
            </div>

            <div>
              <h4 className="text-cyan-400 font-mono font-bold text-sm mb-3">3. IMPORTAR COMPONENTES</h4>
              <CodeBlock
                code={`import { Avatar, GlitchButton, CyberCard, Grid } from './components/CyberUI';

function App() {
  return (
    <div className="min-h-screen bg-black p-8">
      <Grid cols={3} gap={4}>
        <CyberCard title="Card 1">
          <GlitchButton variant="primary">Click Me</GlitchButton>
        </CyberCard>
      </Grid>
    </div>
  );
}`}
                language="jsx"
                title="App.jsx"
              />
            </div>
          </div>
        </CyberPanel>

        {/* Footer */}
        <div className="border-t-2 border-gray-800 pt-8 mt-12">
          <div className="flex flex-col items-center gap-4 text-center">
            <div className="flex items-center gap-3">
              <Shield className="text-cyan-400" size={32} />
              <span className="text-cyan-400 font-mono font-bold text-2xl">CYBERSEC UI</span>
            </div>
            <p className="text-gray-600 font-mono text-sm">© 2025 - Biblioteca de Componentes React - Tema Cyberpunk</p>
            <div className="flex items-center gap-2 text-gray-600 font-mono text-xs">
              <Terminal size={14} />
              <span>v1.0.0 | Build 2024.09.30</span>
            </div>
            <div className="flex gap-4 mt-4">
              <div className="px-4 py-2 bg-gray-950 border border-cyan-500 rounded">
                <p className="text-cyan-400 font-mono text-xs">10+ Componentes</p>
              </div>
              <div className="px-4 py-2 bg-gray-950 border border-green-500 rounded">
                <p className="text-green-400 font-mono text-xs">100% Responsivo</p>
              </div>
              <div className="px-4 py-2 bg-gray-950 border border-yellow-500 rounded">
                <p className="text-yellow-400 font-mono text-xs">Dark Theme</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
import React, { useState, useEffect, useRef } from "react";
import {
  Shield,
  Lock,
  Terminal,
  AlertTriangle,
  CheckCircle,
  XCircle,
  Cpu,
  Activity,
  Eye,
  EyeOff,
  Wifi,
  Server,
  HardDrive,
  Zap,
  Code,
  Database,
  X,
  ChevronDown,
  TrendingUp,
  TrendingDown,
  ChevronRight,
  Home,
  Bell,
  Info,
  Menu,
  User,
  Settings,
  LogOut,
  Search,
  Filter,
  MoreVertical,
  Upload,
  GripVertical,
} from "lucide-react";

// Avatar Component
const Avatar = ({ src, name, size = "md", status, tooltip }) => {
  const sizes = {
    sm: "w-8 h-8 text-xs",
    md: "w-12 h-12 text-sm",
    lg: "w-16 h-16 text-base",
    xl: "w-24 h-24 text-xl",
  };

  const statusColors = {
    online: "bg-green-400",
    offline: "bg-gray-600",
    busy: "bg-red-400",
    away: "bg-yellow-400",
  };

  const initials =
    name
      ?.split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase() || "?";

  const avatar = (
    <div className="relative inline-block">
      <div
        className={`${sizes[size]} rounded-full border-2 border-cyan-400 overflow-hidden bg-gray-900 flex items-center justify-center font-mono font-bold text-cyan-400`}
      >
        {src ? <img src={src} alt={name} className="w-full h-full object-cover" /> : <span>{initials}</span>}
      </div>
      {status && (
        <div
          className={`absolute bottom-0 right-0 w-3 h-3 rounded-full border-2 border-black ${statusColors[status]}`}
        />
      )}
    </div>
  );

  return tooltip ? <Tooltip content={tooltip}>{avatar}</Tooltip> : avatar;
};

// Toolbar Component
const Toolbar = ({ children, position = "top" }) => {
  const positions = {
    top: "top-0 left-0 right-0 border-b-2",
    bottom: "bottom-0 left-0 right-0 border-t-2",
  };

  return (
    <div
      className={`${positions[position]} bg-gray-950 border-cyan-500 px-4 py-3 flex items-center justify-between gap-4`}
    >
      {children}
    </div>
  );
};

// Drag and Drop Zone Component
const DragDropZone = ({ onDrop, accept = "*" }) => {
  const [isDragging, setIsDragging] = useState(false);
  const [files, setFiles] = useState([]);

  const handleDragOver = (e) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setIsDragging(false);
    const droppedFiles = Array.from(e.dataTransfer.files);
    setFiles((prev) => [...prev, ...droppedFiles]);
    onDrop?.(droppedFiles);
  };

  const handleFileInput = (e) => {
    const selectedFiles = Array.from(e.target.files);
    setFiles((prev) => [...prev, ...selectedFiles]);
    onDrop?.(selectedFiles);
  };

  const removeFile = (index) => {
    setFiles((prev) => prev.filter((_, i) => i !== index));
  };

  return (
    <div className="space-y-4">
      <div
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
        className={`border-2 border-dashed rounded-lg p-8 text-center transition-all ${
          isDragging ? "border-cyan-400 bg-cyan-400/10 scale-105" : "border-gray-700 hover:border-cyan-500"
        }`}
      >
        <Upload className="mx-auto mb-4 text-cyan-400" size={48} />
        <p className="text-cyan-400 font-mono font-bold mb-2">
          {isDragging ? "SOLTE OS ARQUIVOS AQUI" : "ARRASTE ARQUIVOS AQUI"}
        </p>
        <p className="text-gray-500 font-mono text-xs mb-4">ou clique para selecionar</p>
        <input type="file" multiple accept={accept} onChange={handleFileInput} className="hidden" id="file-input" />
        <label htmlFor="file-input">
          <span className="inline-block px-4 py-2 bg-cyan-500 text-black font-mono font-bold rounded cursor-pointer hover:bg-cyan-600 transition-colors">
            SELECIONAR ARQUIVOS
          </span>
        </label>
      </div>

      {files.length > 0 && (
        <div className="space-y-2">
          {files.map((file, idx) => (
            <div
              key={idx}
              className="flex items-center justify-between bg-gray-950 border border-cyan-500 rounded px-4 py-2"
            >
              <span className="text-green-400 font-mono text-sm">{file.name}</span>
              <button onClick={() => removeFile(idx)} className="text-red-400 hover:text-red-300">
                <X size={16} />
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

// Skeleton Loader Component
const Skeleton = ({ variant = "text", width, height, className = "" }) => {
  const variants = {
    text: "h-4 rounded",
    circle: "rounded-full",
    rect: "rounded",
    card: "h-48 rounded-lg",
  };

  return (
    <div className={`bg-gray-800 animate-pulse ${variants[variant]} ${className}`} style={{ width, height }}>
      <div className="w-full h-full bg-gradient-to-r from-transparent via-gray-700 to-transparent animate-shimmer" />
    </div>
  );
};

// Side Navigation Component
const SideNav = ({ items, isOpen, onClose }) => {
  return (
    <>
      {/* Mobile Overlay */}
      {isOpen && <div className="fixed inset-0 bg-black/80 z-40 lg:hidden" onClick={onClose} />}

      {/* Side Navigation */}
      <div
        className={`
        fixed top-0 left-0 h-full w-64 bg-gray-950 border-r-2 border-cyan-500 z-50
        transform transition-transform duration-300 lg:translate-x-0
        ${isOpen ? "translate-x-0" : "-translate-x-full"}
      `}
      >
        <div className="p-4 border-b-2 border-cyan-500 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Shield className="text-cyan-400" size={24} />
            <span className="text-cyan-400 font-mono font-bold">CYBERUI</span>
          </div>
          <button onClick={onClose} className="lg:hidden text-cyan-400">
            <X size={20} />
          </button>
        </div>

        <nav className="p-4 space-y-2">
          {items.map((item, idx) => (
            <a
              key={idx}
              href={item.href}
              className={`
                flex items-center gap-3 px-4 py-3 rounded font-mono text-sm
                transition-colors group
                ${item.active ? "bg-cyan-500 text-black font-bold" : "text-cyan-400 hover:bg-cyan-400/10"}
              `}
            >
              {item.icon && <item.icon size={18} />}
              <span>{item.label}</span>
              {item.badge && (
                <span className="ml-auto bg-red-500 text-white text-xs px-2 py-0.5 rounded-full">{item.badge}</span>
              )}
            </a>
          ))}
        </nav>

        <div className="absolute bottom-0 left-0 right-0 p-4 border-t-2 border-cyan-500">
          <button className="w-full flex items-center gap-3 px-4 py-3 rounded font-mono text-sm text-red-400 hover:bg-red-400/10 transition-colors">
            <LogOut size={18} />
            <span>SAIR</span>
          </button>
        </div>
      </div>
    </>
  );
};

// Card Component
const CyberCard = ({ title, subtitle, image, children, actions, hoverable = true }) => {
  return (
    <div
      className={`
      bg-gray-950 border-2 border-gray-700 rounded-lg overflow-hidden
      transition-all duration-300
      ${hoverable ? "hover:border-cyan-400 hover:shadow-lg hover:shadow-cyan-400/20 hover:-translate-y-1" : ""}
    `}
    >
      {image && (
        <div className="relative h-48 bg-gray-900 overflow-hidden">
          <img src={image} alt={title} className="w-full h-full object-cover" />
          <div className="absolute inset-0 bg-gradient-to-t from-gray-950 to-transparent" />
        </div>
      )}

      <div className="p-4 space-y-3">
        {(title || subtitle) && (
          <div>
            {title && <h3 className="text-cyan-400 font-mono font-bold">{title}</h3>}
            {subtitle && <p className="text-gray-500 font-mono text-xs mt-1">{subtitle}</p>}
          </div>
        )}

        {children && <div className="text-gray-400 font-mono text-sm">{children}</div>}

        {actions && <div className="flex gap-2 pt-2">{actions}</div>}
      </div>
    </div>
  );
};

// Grid Component
const Grid = ({ children, cols = 3, gap = 4 }) => {
  const colClasses = {
    1: "grid-cols-1",
    2: "grid-cols-1 md:grid-cols-2",
    3: "grid-cols-1 md:grid-cols-2 lg:grid-cols-3",
    4: "grid-cols-1 md:grid-cols-2 lg:grid-cols-4",
  };

  const gapClasses = {
    2: "gap-2",
    4: "gap-4",
    6: "gap-6",
    8: "gap-8",
  };

  return <div className={`grid ${colClasses[cols]} ${gapClasses[gap]}`}>{children}</div>;
};

// Draggable List Item Component
const DraggableListItem = ({ children, onDragStart, onDragEnd, onDragOver, draggable = true }) => {
  return (
    <div
      draggable={draggable}
      onDragStart={onDragStart}
      onDragEnd={onDragEnd}
      onDragOver={onDragOver}
      className="bg-gray-950 border-2 border-cyan-500 rounded-lg p-4 cursor-move hover:border-cyan-400 transition-all group"
    >
      <div className="flex items-center gap-3">
        {draggable && <GripVertical className="text-gray-600 group-hover:text-cyan-400 transition-colors" size={20} />}
        <div className="flex-1">{children}</div>
      </div>
    </div>
  );
};

// Tooltip Component
const Tooltip = ({ children, content, position = "top" }) => {
  const [show, setShow] = useState(false);
  const positions = {
    top: "bottom-full left-1/2 -translate-x-1/2 mb-2",
    bottom: "top-full left-1/2 -translate-x-1/2 mt-2",
    left: "right-full top-1/2 -translate-y-1/2 mr-2",
    right: "left-full top-1/2 -translate-y-1/2 ml-2",
  };

  return (
    <div className="relative inline-block" onMouseEnter={() => setShow(true)} onMouseLeave={() => setShow(false)}>
      {children}
      {show && (
        <div className={`absolute z-50 ${positions[position]} whitespace-nowrap`}>
          <div className="bg-gray-900 border-2 border-cyan-400 rounded px-3 py-2 text-xs font-mono text-cyan-400 shadow-lg shadow-cyan-400/20">
            {content}
          </div>
        </div>
      )}
    </div>
  );
};

// Toast System
const ToastContainer = ({ toasts, removeToast }) => {
  return (
    <div className="fixed top-4 right-4 z-50 space-y-3 max-w-md">
      {toasts.map((toast) => (
        <Toast key={toast.id} {...toast} onClose={() => removeToast(toast.id)} />
      ))}
    </div>
  );
};

const Toast = ({ type, title, message, onClose, duration = 5000 }) => {
  useEffect(() => {
    const timer = setTimeout(onClose, duration);
    return () => clearTimeout(timer);
  }, [duration, onClose]);

  const types = {
    info: { icon: Info, color: "border-cyan-400 bg-cyan-400/10", iconColor: "text-cyan-400" },
    success: { icon: CheckCircle, color: "border-green-400 bg-green-400/10", iconColor: "text-green-400" },
    warning: { icon: AlertTriangle, color: "border-yellow-400 bg-yellow-400/10", iconColor: "text-yellow-400" },
    error: { icon: XCircle, color: "border-red-400 bg-red-400/10", iconColor: "text-red-400" },
  };

  const config = types[type];
  const Icon = config.icon;

  return (
    <div className={`border-2 ${config.color} rounded-lg p-4 font-mono shadow-2xl`}>
      <div className="flex items-start gap-3">
        <Icon className={config.iconColor} size={20} />
        <div className="flex-1">
          <h4 className={`${config.iconColor} font-bold text-sm uppercase mb-1`}>{title}</h4>
          <p className="text-gray-400 text-xs">{message}</p>
        </div>
        <button onClick={onClose} className={`${config.iconColor} hover:opacity-70`}>
          <X size={16} />
        </button>
      </div>
    </div>
  );
};

// Glitch Button
const GlitchButton = ({ children, onClick, variant = "primary", disabled = false, size = "md", tooltip }) => {
  const [glitch, setGlitch] = useState(false);

  const variants = {
    primary: "bg-cyan-500 hover:bg-cyan-600 text-black",
    danger: "bg-red-500 hover:bg-red-600 text-white",
    success: "bg-green-500 hover:bg-green-600 text-black",
    ghost: "bg-transparent border-cyan-400 text-cyan-400 hover:bg-cyan-400/10",
  };

  const sizes = {
    sm: "px-3 py-1 text-xs",
    md: "px-6 py-2 text-sm",
    lg: "px-8 py-3 text-base",
  };

  const handleClick = (e) => {
    if (disabled) return;
    setGlitch(true);
    setTimeout(() => setGlitch(false), 200);
    onClick?.(e);
  };

  const button = (
    <button
      onClick={handleClick}
      disabled={disabled}
      className={`
        ${variants[variant]}
        ${sizes[size]}
        font-mono font-bold uppercase tracking-wider
        border-2 border-current rounded
        transition-all duration-150
        ${glitch ? "scale-95 opacity-80" : "scale-100"}
        ${disabled ? "opacity-50 cursor-not-allowed" : "hover:shadow-lg hover:shadow-current/50"}
      `}
    >
      {children}
    </button>
  );

  return tooltip ? <Tooltip content={tooltip}>{button}</Tooltip> : button;
};

// Breadcrumb
const Breadcrumb = ({ items }) => {
  return (
    <nav className="flex items-center space-x-2 font-mono text-sm">
      {items.map((item, idx) => (
        <React.Fragment key={idx}>
          {idx > 0 && <ChevronRight size={14} className="text-gray-600" />}
          {item.href ? (
            <a
              href={item.href}
              className={`${
                idx === items.length - 1 ? "text-cyan-400" : "text-gray-500 hover:text-cyan-400"
              } transition-colors flex items-center gap-1`}
            >
              {item.icon && <item.icon size={14} />}
              {item.label}
            </a>
          ) : (
            <span className={`${idx === items.length - 1 ? "text-cyan-400" : "text-gray-500"} flex items-center gap-1`}>
              {item.icon && <item.icon size={14} />}
              {item.label}
            </span>
          )}
        </React.Fragment>
      ))}
    </nav>
  );
};

// Pagination
const Pagination = ({ currentPage, totalPages, onPageChange }) => {
  const getPageNumbers = () => {
    const pages = [];
    const showPages = 5;
    let start = Math.max(1, currentPage - Math.floor(showPages / 2));
    let end = Math.min(totalPages, start + showPages - 1);

    if (end - start < showPages - 1) {
      start = Math.max(1, end - showPages + 1);
    }

    for (let i = start; i <= end; i++) {
      pages.push(i);
    }
    return pages;
  };

  return (
    <div className="flex items-center justify-center gap-2 font-mono">
      <button
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage === 1}
        className="px-3 py-1 border-2 border-cyan-500 rounded text-cyan-400 disabled:opacity-30 disabled:cursor-not-allowed hover:bg-cyan-400/10 transition-colors"
      >
        ‹
      </button>

      {getPageNumbers().map((page) => (
        <button
          key={page}
          onClick={() => onPageChange(page)}
          className={`px-3 py-1 border-2 rounded transition-colors ${
            page === currentPage
              ? "bg-cyan-500 border-cyan-500 text-black font-bold"
              : "border-cyan-500 text-cyan-400 hover:bg-cyan-400/10"
          }`}
        >
          {page}
        </button>
      ))}

      <button
        onClick={() => onPageChange(currentPage + 1)}
        disabled={currentPage === totalPages}
        className="px-3 py-1 border-2 border-cyan-500 rounded text-cyan-400 disabled:opacity-30 disabled:cursor-not-allowed hover:bg-cyan-400/10 transition-colors"
      >
        ›
      </button>
    </div>
  );
};

// CyberPanel
const CyberPanel = ({ title, icon: Icon, children, highlight = false }) => {
  return (
    <div
      className={`
      bg-gray-950 border-2 rounded-lg overflow-hidden
      ${highlight ? "border-cyan-400 shadow-lg shadow-cyan-400/20" : "border-gray-700"}
    `}
    >
      <div className="bg-gradient-to-r from-gray-900 to-gray-800 px-4 py-3 border-b-2 border-current">
        <div className="flex items-center gap-2 font-mono">
          {Icon && <Icon size={18} className="text-cyan-400" />}
          <span className="text-cyan-400 font-bold">{title}</span>
        </div>
      </div>
      <div className="p-4">{children}</div>
    </div>
  );
};

// Demo App
export default function CyberSecUIDemo() {
  const [sideNavOpen, setSideNavOpen] = useState(false);
  const [toasts, setToasts] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [draggedItem, setDraggedItem] = useState(null);
  const [listItems, setListItems] = useState([
    { id: 1, text: "Configurar Firewall" },
    { id: 2, text: "Atualizar Sistema" },
    { id: 3, text: "Verificar Logs" },
    { id: 4, text: "Backup de Dados" },
  ]);

  const addToast = (type, title, message) => {
    const id = Date.now();
    setToasts((prev) => [...prev, { id, type, title, message }]);
  };

  const removeToast = (id) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  const sideNavItems = [
    { icon: Home, label: "Dashboard", href: "#", active: true },
    { icon: Shield, label: "Security", href: "#", badge: "3" },
    { icon: Server, label: "Servers", href: "#" },
    { icon: Activity, label: "Monitoring", href: "#" },
    { icon: Settings, label: "Settings", href: "#" },
  ];

  const breadcrumbItems = [
    { label: "Dashboard", icon: Home, href: "#" },
    { label: "Components", icon: Code, href: "#" },
    { label: "Library", icon: Database },
  ];

  const handleDragStart = (index) => {
    setDraggedItem(index);
  };

  const handleDragOver = (e, index) => {
    e.preventDefault();
    if (draggedItem === null || draggedItem === index) return;

    const newItems = [...listItems];
    const draggedContent = newItems[draggedItem];
    newItems.splice(draggedItem, 1);
    newItems.splice(index, 0, draggedContent);

    setListItems(newItems);
    setDraggedItem(index);
  };

  const handleDragEnd = () => {
    setDraggedItem(null);
  };

  return (
    <div className="min-h-screen bg-black">
      <ToastContainer toasts={toasts} removeToast={removeToast} />
      <SideNav items={sideNavItems} isOpen={sideNavOpen} onClose={() => setSideNavOpen(false)} />

      {/* Main Content */}
      <div className="lg:ml-64">
        {/* Toolbar */}
        <Toolbar position="top">
          <div className="flex items-center gap-4">
            <button onClick={() => setSideNavOpen(true)} className="lg:hidden text-cyan-400 hover:text-cyan-300">
              <Menu size={24} />
            </button>
            <Shield className="text-cyan-400" size={24} />
            <span className="text-cyan-400 font-mono font-bold hidden md:block">CYBERSEC UI v5.0</span>
          </div>

          <div className="flex items-center gap-4">
            <Tooltip content="Pesquisar">
              <button className="text-cyan-400 hover:text-cyan-300">
                <Search size={20} />
              </button>
            </Tooltip>
            <Tooltip content="Notificações">
              <button className="text-cyan-400 hover:text-cyan-300 relative">
                <Bell size={20} />
                <span className="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full" />
              </button>
            </Tooltip>
            <Avatar name="Admin User" size="sm" status="online" tooltip="Admin User - Online" />
          </div>
        </Toolbar>

        {/* Page Content */}
        <div className="p-8 space-y-6">
          {/* Header */}
          <div className="space-y-4">
            <h1 className="text-4xl font-bold text-cyan-400 font-mono flex items-center gap-3">
              <Code size={40} />
              BIBLIOTECA COMPLETA
            </h1>
            <Breadcrumb items={breadcrumbItems} />
          </div>

          {/* Avatar Showcase */}
          <CyberPanel title="AVATARS & USER PROFILES" icon={User} highlight>
            <div className="flex flex-wrap items-center gap-6">
              <Avatar name="John Doe" size="sm" status="online" />
              <Avatar name="Jane Smith" size="md" status="busy" />
              <Avatar name="Bob Wilson" size="lg" status="away" />
              <Avatar name="Alice Johnson" size="xl" status="offline" />
            </div>
          </CyberPanel>

          {/* Cards Grid */}
          <CyberPanel title="CARDS GRID SYSTEM" icon={Database}>
            <Grid cols={3} gap={4}>
              <CyberCard
                title="Sistema de Firewall"
                subtitle="Proteção em Tempo Real"
                actions={
                  <>
                    <GlitchButton size="sm" variant="primary">
                      ATIVAR
                    </GlitchButton>
                    <GlitchButton size="sm" variant="ghost">
                      DETALHES
                    </GlitchButton>
                  </>
                }
              >
                <p>Monitoramento ativo de 1.2M conexões/s</p>
              </CyberCard>

              <CyberCard
                title="Análise de Ameaças"
                subtitle="AI-Powered Detection"
                actions={
                  <>
                    <GlitchButton size="sm" variant="success">
                      SCAN
                    </GlitchButton>
                  </>
                }
              >
                <p>47 ameaças bloqueadas hoje</p>
              </CyberCard>

              <CyberCard
                title="Backup Automático"
                subtitle="Cloud Storage"
                actions={
                  <>
                    <GlitchButton size="sm" variant="ghost">
                      CONFIGURAR
                    </GlitchButton>
                  </>
                }
              >
                <p>Último backup: 2 horas atrás</p>
              </CyberCard>
            </Grid>
          </CyberPanel>

          {/* Drag and Drop */}
          <CyberPanel title="DRAG & DROP FILE UPLOAD" icon={Upload}>
            <DragDropZone
              onDrop={(files) => addToast("success", "Upload", `${files.length} arquivo(s) adicionado(s)`)}
              accept="*"
            />
          </CyberPanel>

          {/* Draggable List */}
          <CyberPanel title="DRAGGABLE TASK LIST" icon={Activity}>
            <div className="space-y-3">
              {listItems.map((item, index) => (
                <DraggableListItem
                  key={item.id}
                  onDragStart={() => handleDragStart(index)}
                  onDragOver={(e) => handleDragOver(e, index)}
                  onDragEnd={handleDragEnd}
                >
                  <div className="flex items-center justify-between">
                    <span className="text-green-400 font-mono">{item.text}</span>
                    <button className="text-gray-600 hover:text-cyan-400">
                      <MoreVertical size={16} />
                    </button>
                  </div>
                </DraggableListItem>
              ))}
            </div>
          </CyberPanel>

          {/* Skeleton Loaders */}
          <CyberPanel title="SKELETON LOADERS" icon={Cpu}>
            <div className="space-y-4">
              <div className="flex items-center gap-4">
                <Skeleton variant="circle" width="48px" height="48px" />
                <div className="flex-1 space-y-2">
                  <Skeleton variant="text" width="60%" />
                  <Skeleton variant="text" width="40%" />
                </div>
              </div>
              <Skeleton variant="card" />
              <div className="space-y-2">
                <Skeleton variant="text" width="100%" />
                <Skeleton variant="text" width="90%" />
                <Skeleton variant="text" width="95%" />
              </div>
            </div>
          </CyberPanel>

          {/* Toast Demo */}
          <CyberPanel title="TOAST NOTIFICATIONS" icon={Bell}>
            <div className="flex flex-wrap gap-3">
              <GlitchButton
                onClick={() => addToast("info", "Info", "Sistema operando normalmente")}
                variant="ghost"
                size="sm"
              >
                INFO
              </GlitchButton>
              <GlitchButton
                onClick={() => addToast("success", "Sucesso", "Operação concluída")}
                variant="success"
                size="sm"
              >
                SUCCESS
              </GlitchButton>
              <GlitchButton
                onClick={() => addToast("warning", "Atenção", "Atualização disponível")}
                variant="ghost"
                size="sm"
              >
                WARNING
              </GlitchButton>
              <GlitchButton onClick={() => addToast("error", "Erro", "Falha na conexão")} variant="danger" size="sm">
                ERROR
              </GlitchButton>
            </div>
          </CyberPanel>

          {/* Pagination */}
          <CyberPanel title="PAGINATION CONTROLS" icon={Filter}>
            <div className="space-y-4">
              <p className="text-gray-400 font-mono text-sm">Página {currentPage} de 10</p>
              <Pagination currentPage={currentPage} totalPages={10} onPageChange={setCurrentPage} />
            </div>
          </CyberPanel>

          {/* Buttons Showcase */}
          <CyberPanel title="GLITCH BUTTONS" icon={Zap}>
            <div className="flex flex-wrap gap-4">
              <GlitchButton variant="primary" size="sm">
                SMALL
              </GlitchButton>
              <GlitchButton variant="primary" size="md">
                MEDIUM
              </GlitchButton>
              <GlitchButton variant="primary" size="lg">
                LARGE
              </GlitchButton>
              <GlitchButton variant="danger">DANGER</GlitchButton>
              <GlitchButton variant="success">SUCCESS</GlitchButton>
              <GlitchButton variant="ghost">GHOST</GlitchButton>
              <GlitchButton disabled>DISABLED</GlitchButton>
              <GlitchButton variant="primary" tooltip="Clique aqui para executar">
                WITH TOOLTIP
              </GlitchButton>
            </div>
          </CyberPanel>

          {/* Status Indicators */}
          <CyberPanel title="SYSTEM STATUS INDICATORS" icon={Activity} highlight>
            <Grid cols={4} gap={4}>
              <div className="bg-gray-900 border-2 border-green-500 rounded-lg p-4 text-center">
                <CheckCircle className="mx-auto mb-2 text-green-400" size={32} />
                <p className="text-green-400 font-mono font-bold">ONLINE</p>
                <p className="text-gray-500 font-mono text-xs mt-1">Sistema Operacional</p>
              </div>

              <div className="bg-gray-900 border-2 border-yellow-500 rounded-lg p-4 text-center">
                <AlertTriangle className="mx-auto mb-2 text-yellow-400" size={32} />
                <p className="text-yellow-400 font-mono font-bold">WARNING</p>
                <p className="text-gray-500 font-mono text-xs mt-1">Alta Utilização CPU</p>
              </div>

              <div className="bg-gray-900 border-2 border-red-500 rounded-lg p-4 text-center">
                <XCircle className="mx-auto mb-2 text-red-400" size={32} />
                <p className="text-red-400 font-mono font-bold">CRITICAL</p>
                <p className="text-gray-500 font-mono text-xs mt-1">Backup Falhou</p>
              </div>

              <div className="bg-gray-900 border-2 border-cyan-500 rounded-lg p-4 text-center">
                <Wifi className="mx-auto mb-2 text-cyan-400" size={32} />
                <p className="text-cyan-400 font-mono font-bold">CONNECTED</p>
                <p className="text-gray-500 font-mono text-xs mt-1">Rede Estável</p>
              </div>
            </Grid>
          </CyberPanel>

          {/* Footer */}
          <div className="border-t-2 border-gray-800 pt-6 mt-8">
            <div className="flex flex-col md:flex-row items-center justify-between gap-4 text-gray-600 font-mono text-xs">
              <p>© 2025 CYBERSEC UI - Todos os direitos reservados</p>
              <p className="flex items-center gap-2">
                <Terminal size={14} />
                Sistema v5.0.0 | Build 2024.09.30
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
