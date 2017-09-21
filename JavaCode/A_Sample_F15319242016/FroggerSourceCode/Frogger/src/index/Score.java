package index;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class Score {
	private static BufferedWriter write;
	private static File scoreFile;

	// new score
	public static void newScore() {
		try {
			// creating a text file
			scoreFile = new File("score.txt");
			if (!scoreFile.exists()) {
				scoreFile.createNewFile();
			}

			FileWriter fileWriter = new FileWriter(scoreFile.getAbsoluteFile(),
					true);
			setWrite(new BufferedWriter(fileWriter));

		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	// add score, adds a score when level is complete
	public static void addScore(int score) {
		// creates string of the score for printing to text file
		String scoreStr = String.valueOf(score);
		try {
			// writes the string to the file
			getWrite().append(scoreStr);
			getWrite().newLine();
		} catch (IOException e) {
			e.printStackTrace();
		}

		// closing writer if on last level
		if (Main.isLevel2Run()) {
			try {
				write.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

	}

	// sum score
	public static void sumScore() {
		int scoreSum = 0;
		FileReader fileReader;
		// reading previous scores of play through
		try {
			fileReader = new FileReader("score.txt");
			BufferedReader reader = new BufferedReader(fileReader);

			// there is always a maximum of 2 lines
			int lines = 2;
			String[] scores = new String[lines];

			// adding saved scores from text file
			for (int i = 0; i < lines; i++) {
				scores[i] = reader.readLine();
			}

			int score1 = Integer.valueOf(scores[0]);
			// if there are 2 scores, adding them together
			if (scores[1] != null) {
				int score2 = Integer.valueOf(scores[1]);
				scoreSum = score1 + score2;
			} else { // if only one score, setting it as the sum
				scoreSum = score1;
			}
			
			fileReader.close();
			reader.close();

		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		// creating total score new file
		try {
			// creating a text file
			File totalScoreFile = new File("totalScores.txt");

			// creating file
			if (!totalScoreFile.exists()) {
				totalScoreFile.createNewFile();
			}

			FileWriter fileWriter = new FileWriter(
					totalScoreFile.getAbsoluteFile(), true);
			BufferedWriter scoreWriter = new BufferedWriter(fileWriter); // main
																			// writer
																			// for
																			// scores

			// writing total score to new file
			String totalScoreStr = String.valueOf(scoreSum);
			scoreWriter.append(totalScoreStr);
			scoreWriter.newLine();
			scoreWriter.close();
			
		} catch (IOException e) {
			e.printStackTrace();
		}

		// deleting previous scores file, making room for a new playthrough
		Path path = scoreFile.toPath();
		try {
			Files.delete(path);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static String[] readFinalScores() {
		FileReader fileReader;
		String[] scores = null;
		// reading previous scores of play through
		try {
			fileReader = new FileReader("totalScores.txt");

			BufferedReader reader = new BufferedReader(fileReader);

			// will save 5 scores
			int lines = 5;
			scores = new String[lines];

			// creating an array of scores to be printed on leaderboard
			for (int i = 0; i < lines; i++) {
				scores[i] = reader.readLine();
			}

			fileReader.close();
			reader.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return scores;
	}

	public static BufferedWriter getWrite() {
		return write;
	}

	public static void setWrite(BufferedWriter write) {
		Score.write = write;
	}
}
