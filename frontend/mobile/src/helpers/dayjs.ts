import dayjs from 'dayjs';
import 'dayjs/locale/ru';
import 'dayjs/locale/en';
import customParseFormat from 'dayjs/plugin/customParseFormat';
import localeData from 'dayjs/plugin/localeData';

dayjs.extend(localeData);
dayjs.extend(customParseFormat);

export default dayjs;
