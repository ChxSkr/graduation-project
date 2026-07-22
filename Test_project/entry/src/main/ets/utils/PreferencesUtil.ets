import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { Logger } from './Logger';
import { AppConstants } from '../constant/AppConstants';

export class PreferencesUtil {
  private static prefs: preferences.Preferences | null = null;

  static init(context: common.UIAbilityContext): void {
    try {
      PreferencesUtil.prefs = preferences.getPreferencesSync(context, { name: AppConstants.PREFS_NAME });
      Logger.info('Preferences init success');
    } catch (e) {
      Logger.error('Preferences init failed: ' + JSON.stringify(e));
    }
  }

  static putString(key: string, value: string): void {
    if (!PreferencesUtil.prefs) return;
    try {
      PreferencesUtil.prefs.putSync(key, value);
      PreferencesUtil.prefs.flushSync();
    } catch (e) {
      Logger.error('putString failed: ' + key);
    }
  }

  static getString(key: string, defValue: string = ''): string {
    if (!PreferencesUtil.prefs) return defValue;
    try {
      return PreferencesUtil.prefs.getSync(key, defValue) as string;
    } catch (e) {
      return defValue;
    }
  }

  static putNumber(key: string, value: number): void {
    if (!PreferencesUtil.prefs) return;
    try {
      PreferencesUtil.prefs.putSync(key, value);
      PreferencesUtil.prefs.flushSync();
    } catch (e) {
      Logger.error('putNumber failed: ' + key);
    }
  }

  static getNumber(key: string, defValue: number = 0): number {
    if (!PreferencesUtil.prefs) return defValue;
    try {
      return PreferencesUtil.prefs.getSync(key, defValue) as number;
    } catch (e) {
      return defValue;
    }
  }

  static putBoolean(key: string, value: boolean): void {
    if (!PreferencesUtil.prefs) return;
    try {
      PreferencesUtil.prefs.putSync(key, value);
      PreferencesUtil.prefs.flushSync();
    } catch (e) {
      Logger.error('putBoolean failed: ' + key);
    }
  }

  static getBoolean(key: string, defValue: boolean = false): boolean {
    if (!PreferencesUtil.prefs) return defValue;
    try {
      return PreferencesUtil.prefs.getSync(key, defValue) as boolean;
    } catch (e) {
      return defValue;
    }
  }

  static putObject<T>(key: string, value: T): void {
    PreferencesUtil.putString(key, JSON.stringify(value));
  }

  static getObject<T>(key: string, defValue: T): T {
    const str = PreferencesUtil.getString(key, '');
    if (!str) return defValue;
    try {
      return JSON.parse(str) as T;
    } catch (e) {
      Logger.error('getObject parse failed: ' + key);
      return defValue;
    }
  }

  static putArray<T>(key: string, value: T[]): void {
    PreferencesUtil.putString(key, JSON.stringify(value));
  }

  static getArray<T>(key: string, defValue: T[] = []): T[] {
    const str = PreferencesUtil.getString(key, '');
    if (!str) return defValue;
    try {
      return JSON.parse(str) as T[];
    } catch (e) {
      Logger.error('getArray parse failed: ' + key);
      return defValue;
    }
  }

  static remove(key: string): void {
    if (!PreferencesUtil.prefs) return;
    try {
      PreferencesUtil.prefs.deleteSync(key);
      PreferencesUtil.prefs.flushSync();
    } catch (e) {
      Logger.error('remove failed: ' + key);
    }
  }

  static clearAll(): void {
    if (!PreferencesUtil.prefs) return;
    try {
      PreferencesUtil.prefs.clearSync();
      PreferencesUtil.prefs.flushSync();
    } catch (e) {
      Logger.error('clearAll failed');
    }
  }
}
