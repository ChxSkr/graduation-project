import { PreferencesUtil } from '../utils/PreferencesUtil';
import { PrefKeys } from '../constant/AppConstants';
import { MockCourses } from './MockCourses';
import { MockCardData } from './MockCardData';
import { MockNews } from './MockNews';
import { MockLostFound } from './MockLostFound';
import { MockUser } from './MockUser';
import { Logger } from '../utils/Logger';

export class MockDataInitializer {
  static initIfNeeded(): void {
    const inited = PreferencesUtil.getString(PrefKeys.MOCK_INITED, '');
    if (inited === 'true') {
      Logger.info('Mock data already initialized');
      return;
    }

    Logger.info('Initializing mock data...');
    PreferencesUtil.putArray(PrefKeys.COURSE_LIST, MockCourses.getInitialCourses());
    PreferencesUtil.putObject(PrefKeys.CARD_INFO, MockCardData.getCardInfo());
    PreferencesUtil.putArray(PrefKeys.CARD_RECORDS, MockCardData.getRecords());
    PreferencesUtil.putArray(PrefKeys.NEWS_LIST, MockNews.getNewsList());
    PreferencesUtil.putArray(PrefKeys.LOST_FOUND_LIST, MockLostFound.getItemList());
    PreferencesUtil.putObject(PrefKeys.USER_INFO, MockUser.getUserInfo());
    PreferencesUtil.putString(PrefKeys.MOCK_INITED, 'true');
    Logger.info('Mock data initialization completed');
  }

  static resetAll(): void {
    PreferencesUtil.remove(PrefKeys.MOCK_INITED);
    MockDataInitializer.initIfNeeded();
  }
}
