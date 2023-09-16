package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Log;

class PlayState extends FlxState
{
	public static var turnText:FlxText;

	var gameBoard:GameBoard;

	override public function create()
	{
		super.create();

		turnText = new FlxText(0, FlxG.height / 5, 0, "Player 1's Turn!", 12);
		turnText.screenCenter(X);

		var resetGame = new FlxButton(0, 0, "New Game", newGame);
		resetGame.screenCenter(X);
		resetGame.y = FlxG.height - 100;
		newGame();

		add(resetGame);
		add(turnText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (gameBoard.gameWon)
		{
			turnText.text = (gameBoard.turn == "X" ? "Player 1" : "Player 2") + " Wins!";
			return;
		}

		if (gameBoard.turn == "X")
			turnText.text = "Player 1's Turn!";
		else
			turnText.text = "Player 2's Turn!";
	}

	function newGame()
	{
		var buttonSize = 50;
		var gridSize = 3;
		var spacing = 10;

		gameBoard = new GameBoard(gridSize, buttonSize, spacing);
		add(gameBoard.buttonGroup);
	}
}

class GameBoard
{
	public var buttonGroup:FlxTypedGroup<FlxButton> = new FlxTypedGroup();
	public var turn:String = "X";

	var gridSize:Int;

	public var gameWon:Bool = false;

	public function new(gridSize:Int, buttonSize:Int, spacing:Int)
	{
		this.gridSize = gridSize;

		var offset = FlxPoint.get(FlxG.width / 2, FlxG.height / 2).subtract((buttonSize + spacing) * gridSize / 2, (buttonSize + spacing) * gridSize / 2);
		for (i in 0...gridSize)
			for (j in 0...gridSize)
			{
				buttonGroup.add(createButton(j * (buttonSize + spacing) + offset.x, i * (buttonSize + spacing) + offset.y, buttonSize, buttonSize));
			}
	}

	function createButton(?x:Float = 0, ?y:Float = 0, ?width:Int = 25, ?height:Int = 25, ?text:String = ""):FlxButton
	{
		var button = new FlxButton(x, y, text);
		button.makeGraphic(width, height, FlxColor.GRAY, true);
		// offset to center the label in the button
		var labelOffset = FlxPoint.get(0, height / 4);
		// setup the text formatting and center the label in the button
		button.label.setFormat(null, 12, FlxColor.BLUE);
		button.labelOffsets = [labelOffset, labelOffset, labelOffset];
		// assign the callback as on onClick method and bind the button as its arg
		button.onDown.callback = onClick.bind(button);
		return button;
	}

	function onClick(b:FlxButton)
	{
		// dont move if game is over or invalid move
		if (gameWon || b.text != "")
			return;

		// make move
		b.text = turn;

		if (checkWinState())
		{
			gameWon = true;
			PlayState.turnText.text = turn == "X" ? "Player 1 Wins!" : "Player 2 Wins!";
			return;
		}

		// swap turn
		turn = turn == "X" ? "O" : "X";
	}

	// works! just need a better way to handle gamestate
	function checkWinState():Bool
	{
		var it = buttonGroup.iterator();

		// build a matrix representing the game board
		var matrix = [for (i in 0...gridSize) [for (j in 0...gridSize) it.next().text]];
		Log.trace(matrix);

		for (j in 0...gridSize)
		{
			var hScore = 0; // horizontal lines
			var vScore = 0; // vertical lines
			var dTopDownScore = 0; // diagonal from top left to bottom right
			var dBottomUpScore = 0; // diagonal from botto left to top right

			for (i in 0...gridSize)
			{
				hScore += matrix[j][i] == turn ? 1 : 0;
				vScore += matrix[i][j] == turn ? 1 : 0;

				dTopDownScore += matrix[i][i] == turn ? 1 : 0;
				dBottomUpScore += matrix[gridSize - 1 - i][i] == turn ? 1 : 0;
			}

			if (hScore == gridSize || vScore == gridSize || dTopDownScore == gridSize || dBottomUpScore == gridSize)
				return true;
		}

		return false;
	}
}
/**
 * Pretty much done, if I need to add more consider the following:
 *  - Stale game indicator
 *  - AI opponent
 *  - Auto Mode
 *  - Screen effects
 *  - Line showing the winning combo
 *  - Styling/Polish
 *  - scoreboard for player 1/2 (or CPU)
 */
