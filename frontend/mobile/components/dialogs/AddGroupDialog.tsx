import { memo, useState } from 'react';
import { Text, View } from 'react-native';
import { TextInput } from 'react-native-paper';
import { ConfirmDialog } from '@/components/dialogs/ConfirmDialog';
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import { type GroupResponse, groupService } from '@/services/group';

const INPUT_THEME = { roundness: 10 };

type Props = {
  visible: boolean;
  onDismiss: () => void;
  onGroupAdded: (group: GroupResponse) => void;
};

export const AddGroupDialog = memo(
  ({ visible, onDismiss, onGroupAdded }: Readonly<Props>) => {
    const [name, setName] = useState<string>('');
    const [defaultPrice, setDefaultPrice] = useState<string>('');
    const [loading, setLoading] = useState<boolean>(false);
    const [error, setError] = useState<string | null>(null);

    const handlePriceChange = (text: string) => {
      const cleaned = text.replaceAll(/[^0-9.]/g, '');
      const [integerPart, decimalPart] = cleaned.split('.');
      const formatted =
        decimalPart === undefined
          ? integerPart
          : `${integerPart}.${decimalPart.slice(0, 2)}`;
      setDefaultPrice(formatted);
    };

    const handleSubmit = async () => {
      const trimmedName = name.trim();

      if (!trimmedName || loading) {
        return;
      }

      setLoading(true);
      setError(null);

      const trimmedPrice = defaultPrice.trim();
      const price =
        trimmedPrice && !Number.isNaN(Number(trimmedPrice))
          ? Number(trimmedPrice)
          : null;

      try {
        const id = await groupService.createGroup(name.trim(), price);
        const createdGroup = await groupService.getGroupById(id);

        onGroupAdded(createdGroup);

        setName('');
        setDefaultPrice('');
      } catch (err) {
        console.log(err);
        setError('Failed to create group');
      } finally {
        setLoading(false);
      }
    };

    return (
      <ConfirmDialog
        visible={visible}
        title='Add group'
        onConfirm={handleSubmit}
        onDismiss={loading ? undefined : onDismiss}
        disabledConfirm={!name.trim() || loading}
        loading={loading}
      >
        <View style={{ gap: 16 }}>
          <OptionalErrorMessage error={error} />

          <TextInput
            mode='outlined'
            value={name}
            theme={INPUT_THEME}
            onChangeText={setName}
            maxLength={255}
            right={<TextInput.Affix text={`${name.length}/255`} />}
            label={
              <Text>
                Name <Text style={{ color: 'red' }}>*</Text>
              </Text>
            }
          />

          <TextInput
            mode='outlined'
            label='Default Price'
            value={defaultPrice}
            theme={INPUT_THEME}
            keyboardType='decimal-pad'
            onChangeText={handlePriceChange}
          />
        </View>
      </ConfirmDialog>
    );
  }
);
