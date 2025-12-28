import { type Dispatch, memo, type SetStateAction } from 'react';
import { Dialog, Portal, RadioButton } from 'react-native-paper';

type Props = {
  visible: boolean;
  language: 'en' | 'ru';
  setLanguage: Dispatch<SetStateAction<'en' | 'ru'>>;
  onDismiss: () => void;
};

export const LanguageDialog = memo(
  ({ visible, language, setLanguage, onDismiss }: Readonly<Props>) => {
    return (
      <Portal>
        <Dialog
          visible={visible}
          onDismiss={onDismiss}
        >
          <Dialog.Title>Language</Dialog.Title>
          <Dialog.Content>
            <RadioButton.Group
              onValueChange={value => setLanguage(value as 'en' | 'ru')}
              value={language}
            >
              <RadioButton.Item
                label='English'
                value='en'
              />
              <RadioButton.Item
                label='Русский'
                value='ru'
              />
            </RadioButton.Group>
          </Dialog.Content>
        </Dialog>
      </Portal>
    );
  }
);
