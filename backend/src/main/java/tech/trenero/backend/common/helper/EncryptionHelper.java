package tech.trenero.backend.common.helper;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import lombok.NoArgsConstructor;
import lombok.SneakyThrows;

@NoArgsConstructor(access = lombok.AccessLevel.PRIVATE)
public class EncryptionHelper {
  private static final SecureRandom RANDOM = new SecureRandom();
  private static final int KEY_ITERATION_COUNT = 100_000;
  private static final int KEY_SIZE = 32;
  private static final int IV_SIZE = 16;
  private static final int TAG_SIZE = 128;

  public static SecretKey generateKey(char[] password, byte[] salt) {
    try {
      int keySizeBits = KEY_SIZE * 8;

      PBEKeySpec keySpec = new PBEKeySpec(password, salt, KEY_ITERATION_COUNT, keySizeBits);
      SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
      SecretKey temporaryKey = factory.generateSecret(keySpec);

      keySpec.clearPassword();

      return new SecretKeySpec(temporaryKey.getEncoded(), "AES");
    } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
      throw new IllegalStateException("Failed to generate encryption key", e);
    }
  }

  @SneakyThrows
  public static byte[] encrypt(SecretKey key, byte[] clearText) {
    byte[] iv = new byte[IV_SIZE];
    RANDOM.nextBytes(iv);

    Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
    GCMParameterSpec spec = new GCMParameterSpec(TAG_SIZE, iv);
    cipher.init(Cipher.ENCRYPT_MODE, key, spec);

    byte[] cipherText = cipher.doFinal(clearText);
    return concat(iv, cipherText);
  }

  @SneakyThrows
  public static byte[] decrypt(SecretKey key, byte[] cipherMessage) {
    byte[][] parts = split(cipherMessage);
    byte[] iv = parts[0];
    byte[] cipherText = parts[1];

    Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
    GCMParameterSpec spec = new GCMParameterSpec(TAG_SIZE, iv);
    cipher.init(Cipher.DECRYPT_MODE, key, spec);

    return cipher.doFinal(cipherText);
  }

  private static byte[] concat(byte[] iv, byte[] cipherText) {
    byte[] result = new byte[iv.length + cipherText.length];
    System.arraycopy(iv, 0, result, 0, iv.length);
    System.arraycopy(cipherText, 0, result, iv.length, cipherText.length);
    return result;
  }

  private static byte[][] split(byte[] message) {
    byte[] iv = new byte[IV_SIZE];
    byte[] cipherText = new byte[message.length - IV_SIZE];
    System.arraycopy(message, 0, iv, 0, IV_SIZE);
    System.arraycopy(message, IV_SIZE, cipherText, 0, cipherText.length);
    return new byte[][] {iv, cipherText};
  }
}
