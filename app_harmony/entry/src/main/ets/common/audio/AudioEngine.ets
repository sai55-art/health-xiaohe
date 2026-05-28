// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import { audio } from '@kit.AudioKit';
import { util } from '@kit.ArkTS';

/// 语音通话音频引擎（对应 Flutter AudioRecorder + AudioPlayer）。
/// 采集：16kHz / mono / S16LE PCM（DashScope 输入要求），编码 base64 上行。
/// 播放：24kHz / mono / S16LE PCM（DashScope 输出），从队列串行写入渲染。
export class AudioEngine {
  private capturer: audio.AudioCapturer | null = null;
  private renderer: audio.AudioRenderer | null = null;
  private helper: util.Base64Helper = new util.Base64Helper();
  private queue: ArrayBuffer[] = [];
  private draining: boolean = false;
  public muted: boolean = false;
  public onPcm: (b64: string) => void = () => {};

  async startCapture(): Promise<void> {
    const opt: audio.AudioCapturerOptions = {
      streamInfo: {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      },
      capturerInfo: {
        source: audio.SourceType.SOURCE_TYPE_MIC,
        capturerFlags: 0
      }
    };
    this.capturer = await audio.createAudioCapturer(opt);
    this.capturer.on('readData', (buffer: ArrayBuffer) => {
      if (this.muted) {
        return;
      }
      const b64: string = this.helper.encodeToStringSync(new Uint8Array(buffer));
      this.onPcm(b64);
    });
    await this.capturer.start();
  }

  async startPlayback(): Promise<void> {
    const opt: audio.AudioRendererOptions = {
      streamInfo: {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_24000,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      },
      rendererInfo: {
        usage: audio.StreamUsage.STREAM_USAGE_VOICE_COMMUNICATION,
        rendererFlags: 0
      }
    };
    this.renderer = await audio.createAudioRenderer(opt);
    await this.renderer.start();
  }

  // 收到一段 AI 音频（base64 PCM），解码入队并触发串行播放
  enqueue(b64: string): void {
    const bytes: Uint8Array = this.helper.decodeSync(b64);
    this.queue.push(bytes.buffer as ArrayBuffer);
    this.drain();
  }

  private async drain(): Promise<void> {
    if (this.draining || this.renderer === null) {
      return;
    }
    this.draining = true;
    while (this.queue.length > 0 && this.renderer !== null) {
      const buf: ArrayBuffer | undefined = this.queue.shift();
      if (buf !== undefined) {
        await this.renderer.write(buf);
      }
    }
    this.draining = false;
  }

  // 打断：清空待播放队列
  clearQueue(): void {
    this.queue = [];
  }

  async stop(): Promise<void> {
    this.queue = [];
    if (this.capturer !== null) {
      try {
        await this.capturer.stop();
        await this.capturer.release();
      } catch (e) {
      }
      this.capturer = null;
    }
    if (this.renderer !== null) {
      try {
        await this.renderer.stop();
        await this.renderer.release();
      } catch (e) {
      }
      this.renderer = null;
    }
  }
}
