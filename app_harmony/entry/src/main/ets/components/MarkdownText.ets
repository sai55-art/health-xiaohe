// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import { FS } from '../common/theme/Tokens';

interface MdSpan {
  text: string;
  bold: boolean;
}

interface MdBlock {
  type: string; // p / h1 / h2 / h3 / bullet / ordered / code / divider
  text: string; // code 原文 / ordered 序号前缀
  spans: MdSpan[];
}

/// 轻量 Markdown 渲染（对应 Flutter 端 flutter_markdown）。
/// 支持：**粗体**、# ## ### 标题、- * 无序列表、1. 有序列表、--- 分隔线、``` 代码块。
/// 每个块都用单个 Text（行内 Span 混排），不设 width，靠气泡 maxWidth 自然换行，
/// 避免子元素 width('100%') 在内容撑宽的气泡里造成布局歧义、文字溢出被裁。
@Component
export struct MarkdownText {
  @Prop content: string;

  private parseInline(line: string): MdSpan[] {
    const spans: MdSpan[] = [];
    const parts: string[] = line.split('**');
    for (let i = 0; i < parts.length; i++) {
      if (parts[i].length === 0) {
        continue;
      }
      spans.push({ text: parts[i], bold: i % 2 === 1 });
    }
    if (spans.length === 0) {
      spans.push({ text: ' ', bold: false });
    }
    return spans;
  }

  private parseBlocks(src: string): MdBlock[] {
    const blocks: MdBlock[] = [];
    const lines: string[] = src.split('\n');
    let inCode: boolean = false;
    let codeBuf: string = '';
    for (let i = 0; i < lines.length; i++) {
      const raw: string = lines[i];
      const line: string = raw.trim();
      if (line.startsWith('```')) {
        if (inCode) {
          blocks.push({ type: 'code', text: codeBuf, spans: [] });
          codeBuf = '';
          inCode = false;
        } else {
          inCode = true;
        }
        continue;
      }
      if (inCode) {
        codeBuf += (codeBuf.length > 0 ? '\n' : '') + raw;
        continue;
      }
      if (line.length === 0) {
        continue;
      }
      if (line === '---' || line === '***' || line === '___') {
        blocks.push({ type: 'divider', text: '', spans: [] });
      } else if (line.startsWith('#### ')) {
        blocks.push({ type: 'h3', text: '', spans: this.parseInline(line.substring(5)) });
      } else if (line.startsWith('### ')) {
        blocks.push({ type: 'h3', text: '', spans: this.parseInline(line.substring(4)) });
      } else if (line.startsWith('## ')) {
        blocks.push({ type: 'h2', text: '', spans: this.parseInline(line.substring(3)) });
      } else if (line.startsWith('# ')) {
        blocks.push({ type: 'h1', text: '', spans: this.parseInline(line.substring(2)) });
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        blocks.push({ type: 'bullet', text: '', spans: this.parseInline(line.substring(2)) });
      } else {
        const m: RegExpMatchArray | null = line.match(/^(\d+)\.\s+(.*)$/);
        if (m !== null) {
          blocks.push({ type: 'ordered', text: m[1] + '. ', spans: this.parseInline(m[2]) });
        } else {
          blocks.push({ type: 'p', text: '', spans: this.parseInline(line) });
        }
      }
    }
    if (inCode && codeBuf.length > 0) {
      blocks.push({ type: 'code', text: codeBuf, spans: [] });
    }
    return blocks;
  }

  // 单个 Text 渲染一行：可选前缀 Span（列表符号/序号）+ 内容 Span（支持粗体）
  @Builder
  line(prefix: string, spans: MdSpan[], size: number, baseBold: boolean) {
    Text() {
      Span(prefix).fontColor($r('app.color.primary'))
      ForEach(spans, (s: MdSpan) => {
        Span(s.text).fontWeight(s.bold || baseBold ? FontWeight.Bold : FontWeight.Normal)
      }, (s: MdSpan, i: number) => i.toString() + s.text)
    }
    .fontSize(size)
    .fontColor($r('app.color.text_primary'))
    .lineHeight(size + 9)
  }

  build() {
    Column({ space: 6 }) {
      ForEach(this.parseBlocks(this.content), (b: MdBlock) => {
        if (b.type === 'divider') {
          Divider().color($r('app.color.bg_subtle')).margin({ top: 2, bottom: 2 })
        } else if (b.type === 'h1') {
          this.line('', b.spans, 20, true)
        } else if (b.type === 'h2') {
          this.line('', b.spans, 18, true)
        } else if (b.type === 'h3') {
          this.line('', b.spans, 16, true)
        } else if (b.type === 'bullet') {
          this.line('•  ', b.spans, FS.body, false)
        } else if (b.type === 'ordered') {
          this.line(b.text, b.spans, FS.body, false)
        } else if (b.type === 'code') {
          Text(b.text)
            .fontSize(13).fontFamily('monospace')
            .fontColor($r('app.color.text_primary'))
            .backgroundColor($r('app.color.bg_subtle'))
            .borderRadius(8).padding(10)
        } else {
          this.line('', b.spans, FS.body, false)
        }
      }, (b: MdBlock, i: number) => i.toString() + '_' + b.type + '_' + (b.spans.length > 0 ? b.spans[0].text : b.text))
    }
    .alignItems(HorizontalAlign.Start)
  }
}
