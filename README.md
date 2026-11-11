# SnowPad OS (snowpad-os)

> **A fusão híbrida do macOS Snow Leopard (10.6) com o iOS 3.2 (iPad 1) rodando nativamente no Intel Atom N450.**

---

## 💡 A Visão do Projeto

O que acontece quando você pega a estabilidade, a aceleração gráfica 3D real da GPU Intel GMA 3150 e os drivers de hardware do **macOS Snow Leopard (Darwin 10 / XNU 1504)** e substitui o desktop pesado pela interface leve, fluida e instantânea do **SpringBoard / UIKit do iOS 3.2**?

Você obtém o **SnowPad OS**: um sistema operacional ágil, icônico e visualmente deslumbrante, criado especificamente para a tela de 1024x600 do netbook **Itautec Infoway W7020** (Intel Atom N450 / 2GB RAM).

---

## 🏗️ Arquitetura Híbrida

```text
┌────────────────────────────────────────────────────────┐
│     EXPERIÊNCIA DO USUÁRIO (Camada iOS / SpringBoard)  │
│  SpringBoard.app (Home screen clássica, Dock, Ícones)  │
│  Apps do iOS: MobileSafari, Calculadora, Notas, iPod   │
│  Frameworks UIKit + GraphicsServices (Mach-O i386)     │
├────────────────────────────────────────────────────────┤
│          PONTE DE FUSÃO (Mouse-to-Touch Shim)          │
│   Converte cliques/touchpad do netbook em toques iOS   │
├────────────────────────────────────────────────────────┤
│      SUBSISTEMA GRÁFICO & DESKTOP (Camada macOS)       │
│   WindowServer + OpenGL + CoreGraphics                 │
│   Aceleração Gráfica 3D QE/CI da Intel GMA 3150        │
├────────────────────────────────────────────────────────┤
│            KERNEL & DRIVERS (Darwin / XNU)             │
│   XNU 1504 (Atom Patched) + I/O Kit + Kexts do W7020   │
└────────────────────────────────────────────────────────┘
```

---

## 🎯 Por que essa fusão funciona tão bem no Atom N450?

| Recurso | No iOS Puro (ARM) | No macOS Puro (Desktop) | No SnowPad OS (Fusão) |
| :--- | :--- | :--- | :--- |
| **GPU Acceleration** | Espera PowerVR SGX | Suporta Intel GMA 3150 QE/CI nativo | **Usa o driver GMA 3150 do macOS** |
| **Consumo de RAM** | ~70 MB | ~350 MB a 500 MB | **~80 MB (Ultra-leve para o Atom)** |
| **Resolução de Tela** | 1024x768 (iPad 1) | Várias resoluções | **1024x600 (Encaixe perfeito na largura)** |
| **Entrada** | Somente Touchscreen | Teclado + Mouse | **Touchpad PS/2 convertido em toques iOS** |
| **Multitarefa** | Limitada no iOS 3 | Completa (UNIX Darwin) | **Kernel UNIX completo com UI do iOS** |

---

## 📋 Roadmap & Painel Interativo

O projeto inclui um painel de desenvolvimento interativo com cálculo dinâmico de progresso:

👉 **Abra o arquivo [`TODO.html`](file:///D:/GitHub/snowpad-os/TODO.html) no navegador para acompanhar o progresso!**

---

## 🛠️ Estrutura do Repositório

```text
snowpad-os/
├── TODO.html          # Dashboard interativo com o roadmap completo
├── README.md          # Documentação da arquitetura e especificações
├── .env.example       # Template de variáveis locais e de rede
├── src/
│   ├── shim/          # Código da ponte Mouse-to-Touch (GSEvent)
│   ├── kernel/        # Configurações do kernel Darwin/XNU para Atom
│   └── boot/          # Configuração do bootloader Chameleon / MBR
```

---

## 🚀 Como Contribuir e Testar

Consulte o arquivo `.env.example`, crie seu arquivo local `.env` com os dados do seu ambiente e execute os scripts de compilação da ponte de eventos e dos drivers.
