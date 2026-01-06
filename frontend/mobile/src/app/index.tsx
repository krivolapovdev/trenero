import dayjs from 'dayjs';
import customParseFormat from 'dayjs/plugin/customParseFormat';
import {Redirect} from 'expo-router';

dayjs.extend(customParseFormat);

export default function Index() {
  return <Redirect href='/(auth)' />;
}
