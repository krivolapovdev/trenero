import type { ReactNode } from 'react';
import { StyleSheet } from 'react-native';
import { List, Text, useTheme } from 'react-native-paper';

type Props = { title: string; children: ReactNode };

export function LabeledSection({ title, children }: Readonly<Props>) {
  const theme = useTheme();

  return (
    <>
      <Text style={styles.sectionLabel}>{title}</Text>
      <List.Section
        style={[styles.group, { backgroundColor: theme.colors.surface }]}
      >
        {children}
      </List.Section>
    </>
  );
}

const styles = StyleSheet.create({
  sectionLabel: {
    marginBottom: 6,
    marginLeft: 12,
    fontSize: 13,
    fontWeight: '600',
    opacity: 0.6
  },
  group: {
    borderRadius: 14,
    overflow: 'hidden',
    marginBottom: 20
  }
});
