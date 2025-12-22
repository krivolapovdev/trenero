import { memo, useState } from 'react';
import { Pressable, Text, View } from 'react-native';
import DatePicker from 'react-native-date-picker';
import { TextInput } from 'react-native-paper';
import { ConfirmDialog } from '@/components/dialogs/ConfirmDialog';
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import { type StudentResponse, studentService } from '@/services/student';

const INPUT_THEME = { roundness: 10 };

type Props = {
  visible: boolean;
  onDismiss: () => void;
  onStudentAdded: (student: StudentResponse) => void;
};

export const AddStudentDialog = memo(
  ({ visible, onDismiss, onStudentAdded }: Readonly<Props>) => {
    const [fullName, setFullName] = useState<string>('');
    const [phoneNumber, setPhoneNumber] = useState<string>('');
    const [note, setNote] = useState<string>('');
    const [birthDate, setBirthDate] = useState<Date | null>(null);

    const [isDatePickerOpen, setIsDatePickerOpen] = useState<boolean>(false);
    const [loading, setLoading] = useState<boolean>(false);
    const [error, setError] = useState<string | null>(null);

    const handleSubmit = async () => {
      const trimmedFullName = fullName.trim();

      if (!trimmedFullName || loading) {
        return;
      }

      setLoading(true);
      setError(null);

      const trimmedPhoneNumber = phoneNumber.trim() || null;
      const trimmedNote = note.trim() || null;

      try {
        const studentId = await studentService.createStudent(
          trimmedFullName,
          trimmedPhoneNumber,
          birthDate,
          trimmedNote
        );

        const createdStudent = await studentService.getStudentById(studentId);

        onStudentAdded(createdStudent);

        setFullName('');
        setPhoneNumber('');
        setNote('');
        setBirthDate(null);
        setError(null);
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
        title='Add student'
        onConfirm={handleSubmit}
        onDismiss={loading ? undefined : onDismiss}
        disabledConfirm={!fullName.trim() || loading}
        loading={loading}
      >
        <View style={{ gap: 10 }}>
          <OptionalErrorMessage error={error} />

          <TextInput
            mode='outlined'
            value={fullName}
            theme={INPUT_THEME}
            onChangeText={setFullName}
            maxLength={255}
            right={<TextInput.Affix text={`${fullName.length}/255`} />}
            label={
              <Text>
                Full Name <Text style={{ color: 'red' }}>*</Text>
              </Text>
            }
          />

          <TextInput
            mode='outlined'
            label='Phone number'
            value={phoneNumber}
            theme={INPUT_THEME}
            keyboardType='numeric'
            left={<TextInput.Affix text='+' />}
            maxLength={15}
            onChangeText={text => {
              const cleanedText = text.replaceAll(/\D/g, '');
              setPhoneNumber(cleanedText);
            }}
          />

          <TextInput
            mode='outlined'
            label='Note'
            value={note}
            theme={INPUT_THEME}
            onChangeText={setNote}
            maxLength={1023}
            multiline={true}
            right={<TextInput.Affix text={`${note.length}/1023`} />}
          />

          <Pressable onPress={() => setIsDatePickerOpen(true)}>
            <TextInput
              mode='outlined'
              label='Birthday'
              value={birthDate ? birthDate.toLocaleDateString() : ''}
              theme={INPUT_THEME}
              editable={false}
              pointerEvents='none'
              right={
                birthDate && (
                  <TextInput.Icon
                    icon='close'
                    onPress={() => setBirthDate(null)}
                  />
                )
              }
            />
          </Pressable>

          <DatePicker
            modal={true}
            open={isDatePickerOpen}
            date={birthDate || new Date()}
            mode='date'
            maximumDate={new Date()}
            onConfirm={date => {
              setBirthDate(date);
              setIsDatePickerOpen(false);
            }}
            onCancel={() => setIsDatePickerOpen(false)}
          />
        </View>
      </ConfirmDialog>
    );
  }
);
