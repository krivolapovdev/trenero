import { memo, useState } from 'react';
import { Text } from 'react-native';
import { TextInput } from 'react-native-paper';
import { ConfirmDialog } from '@/components/dialogs/ConfirmDialog';
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import { type GroupResponse, groupService } from '@/services/group';

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

    const handleSubmit = async () => {
      if (!name.trim() || loading) {
        return;
      }

      setLoading(true);
      setError(null);

      try {
        const price = defaultPrice.trim() === '' ? null : Number(defaultPrice);
        const id = await groupService.createGroup(name.trim(), price);
        const createdGroup = await groupService.getGroupById(id);
        onGroupAdded(createdGroup.groupResponse);
      } catch (err) {
        console.log(err);
        setError('Failed to create group');
      } finally {
        setName('');
        setDefaultPrice('');
        setLoading(false);
      }
    };

    return (
      <ConfirmDialog
        visible={visible}
        title='Add group'
        onConfirm={handleSubmit}
        onDismiss={onDismiss}
        disabledConfirm={!name.trim()}
        loading={loading}
      >
        <OptionalErrorMessage error={error} />

        <TextInput
          mode='outlined'
          value={name}
          onChangeText={setName}
          maxLength={255}
          style={{ marginBottom: 16 }}
          right={<TextInput.Affix text={`${name.length}/255`} />}
          label={
            <Text>
              Group Name <Text style={{ color: 'red' }}>*</Text>
            </Text>
          }
        />

        <TextInput
          mode='outlined'
          label='Default Price'
          value={defaultPrice}
          keyboardType='numeric'
          onChangeText={text => {
            const cleaned = text.replaceAll(/[^0-9.]/g, '');
            const [integerPart, decimalPart] = cleaned.split('.');
            const formatted =
              decimalPart === undefined
                ? integerPart
                : `${integerPart}.${decimalPart.slice(0, 2)}`;
            setDefaultPrice(formatted);
          }}
        />
      </ConfirmDialog>
    );
  }
);
