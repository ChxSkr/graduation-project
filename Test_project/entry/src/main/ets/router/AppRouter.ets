import { NavPathStack } from '@kit.ArkUI';
import { Logger } from '../utils/Logger';

export class AppRouter {
  static push(stack: NavPathStack, routeName: string, param?: object): void {
    try {
      stack.pushPathByName(routeName, param ?? {});
    } catch (e) {
      Logger.error('push failed: ' + routeName + ', ' + JSON.stringify(e));
    }
  }

  static pop(stack: NavPathStack): void {
    try {
      stack.pop();
    } catch (e) {
      Logger.error('pop failed: ' + JSON.stringify(e));
    }
  }

  static replace(stack: NavPathStack, routeName: string, param?: object): void {
    try {
      stack.replacePathByName(routeName, param ?? {});
    } catch (e) {
      Logger.error('replace failed: ' + routeName + ', ' + JSON.stringify(e));
    }
  }

  static popToRoot(stack: NavPathStack): void {
    try {
      stack.popToIndex(0);
    } catch (e) {
      Logger.error('popToRoot failed: ' + JSON.stringify(e));
    }
  }

  static canPop(stack: NavPathStack): boolean {
    return stack.size() > 1;
  }
}
