// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

/// 视频通话摄像头引擎（对应 Flutter CameraCapture）。
/// 预览输出到 XComponent surface；定时拍照抓 JPEG 帧 → base64 → onFrame 上行。
/// DashScope 视频不需高帧率，默认每 ~1.5s 一帧。
export class CameraEngine {
  private mgr: camera.CameraManager | null = null;
  private input: camera.CameraInput | null = null;
  private session: camera.PhotoSession | null = null;
  private previewOutput: camera.PreviewOutput | null = null;
  private photoOutput: camera.PhotoOutput | null = null;
  private helper: util.Base64Helper = new util.Base64Helper();
  private timer: number = -1;
  public onFrame: (b64: string) => void = () => {};

  async start(context: common.UIAbilityContext, surfaceId: string): Promise<void> {
    this.mgr = camera.getCameraManager(context);
    const devices: Array<camera.CameraDevice> = this.mgr.getSupportedCameras();
    if (devices.length === 0) {
      return;
    }
    let dev: camera.CameraDevice = devices[0];
    for (let i = 0; i < devices.length; i++) {
      if (devices[i].cameraPosition === camera.CameraPosition.CAMERA_POSITION_FRONT) {
        dev = devices[i];
        break;
      }
    }

    const caps: camera.CameraOutputCapability =
      this.mgr.getSupportedOutputCapability(dev, camera.SceneMode.NORMAL_PHOTO);
    const previewProfile: camera.Profile = caps.previewProfiles[0];
    const photoProfile: camera.Profile = caps.photoProfiles[0];

    this.previewOutput = this.mgr.createPreviewOutput(previewProfile, surfaceId);
    this.photoOutput = this.mgr.createPhotoOutput(photoProfile);

    this.photoOutput.on('photoAvailable', async (err: BusinessError, photo: camera.Photo) => {
      if (err) {
        return;
      }
      try {
        const comp: image.Component = await photo.main.getComponent(image.ComponentType.JPEG);
        const b64: string = this.helper.encodeToStringSync(new Uint8Array(comp.byteBuffer));
        this.onFrame('data:image/jpeg;base64,' + b64);
      } catch (e) {
      } finally {
        photo.release();
      }
    });

    this.input = this.mgr.createCameraInput(dev);
    await this.input.open();

    this.session = this.mgr.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
    this.session.beginConfig();
    this.session.addInput(this.input);
    this.session.addOutput(this.previewOutput);
    this.session.addOutput(this.photoOutput);
    await this.session.commitConfig();
    await this.session.start();

    this.timer = setInterval(() => {
      if (this.photoOutput !== null) {
        this.photoOutput.capture();
      }
    }, 1500);
  }

  async stop(): Promise<void> {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    try {
      if (this.session !== null) {
        await this.session.stop();
        await this.session.release();
        this.session = null;
      }
    } catch (e) {
    }
    try {
      if (this.input !== null) {
        await this.input.close();
        this.input = null;
      }
    } catch (e) {
    }
    this.previewOutput = null;
    this.photoOutput = null;
  }
}
