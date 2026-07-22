import hilog from '@ohos.hilog';

export class Logger {
  private static readonly DOMAIN = 0x0001;
  private static readonly TAG = 'CampusLife';

  static debug(msg: string): void {
    hilog.debug(Logger.DOMAIN, Logger.TAG, msg);
  }

  static info(msg: string): void {
    hilog.info(Logger.DOMAIN, Logger.TAG, msg);
  }

  static warn(msg: string): void {
    hilog.warn(Logger.DOMAIN, Logger.TAG, msg);
  }

  static error(msg: string): void {
    hilog.error(Logger.DOMAIN, Logger.TAG, msg);
  }
}
