import { UIAbility, Want, AbilityConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { MockDataInitializer } from '../data/MockDataInitializer';
import { Logger } from '../utils/Logger';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info('EntryAbility onCreate');
    // 初始化 Preferences
    PreferencesUtil.init(this.context);
    // 初始化 Mock 数据（首次启动）
    MockDataInitializer.initIfNeeded();
  }

  onDestroy(): void {
    Logger.info('EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info('onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        Logger.error('Failed to load content, err: ' + JSON.stringify(err));
        return;
      }
      Logger.info('Succeeded in loading content');
    });
  }

  onWindowStageDestroy(): void {
    Logger.info('onWindowStageDestroy');
  }

  onForeground(): void {
    Logger.info('onForeground');
  }

  onBackground(): void {
    Logger.info('onBackground');
  }
}
