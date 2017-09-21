package index;

import java.io.File;
import java.io.IOException;

import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.sound.sampled.FloatControl;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.UnsupportedAudioFileException;

public class Music {

	private static boolean mute = false;

	
	private static Clip clip;
	
	/**
	 * plays a song loop throughout the game
	 */
	public static void backgroundLoop() {

		try {
			AudioInputStream audioStream = AudioSystem.getAudioInputStream(new File("audio/music.wav"));
			clip = AudioSystem.getClip();
			clip.open(audioStream);
			FloatControl volumeControl = (FloatControl) clip.getControl(FloatControl.Type.MASTER_GAIN); // new volume controller
			volumeControl.setValue(-5.0f); // Reduce volume by 5 decibels.
			muteSetting();
		} catch (UnsupportedAudioFileException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (LineUnavailableException e) {
			e.printStackTrace();
		}
	}
	
	// used to mute/unmute song
	public static void muteSetting() {
		if(!isMute()) {
			clip.start();
			clip.loop(Clip.LOOP_CONTINUOUSLY);
		} else {
			clip.stop();
		}
	}


	public static boolean isMute() {
		return mute;
	}


	public static void setMute(boolean mute) {
		Music.mute = mute;
	}
}
