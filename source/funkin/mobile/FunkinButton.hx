package funkin.mobile;

import funkin.graphics.FunkinSprite;
import flixel.input.touch.FlxTouch;
import flixel.input.FlxInput;
import flixel.input.FlxPointer;
import flixel.input.IFlxInput;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * Enum representing the status of the button.
 */
enum abstract FunkinButtonStatus(Int) from Int to Int
{
  var NORMAL = 0;
  var PRESSED = 1;  
}

/**
 * Enum representing the role of the button.
 */
enum FunkinButtonRole
{
  DIRECTION_BUTTON;
  ACTION_BUTTON;
}

/**
 * A simple button class that calls a function when touched.
 */
#if !display
@:generic
#end
class FunkinButton extends FunkinSprite implements IFlxInput
{
  /**
   * The current state of the button, either `FunkinButtonStatus.NORMAL` or `FunkinButtonStatus.PRESSED`.
   */
  public var status:FunkinButtonStatus;

  /**
   * The role of the button, defining its purpose.
   */
  public var role:FunkinButtonRole;

  /**
   * The callback function to call when the button is released.
   */
  public var onUp:Void->Void;

  /**
   * The callback function to call when the button is pressed down.
   */
  public var onDown:Void->Void;

  /**
   * The callback function to call when the button is hovered over.
   */
  public var onOver:Void->Void;

  /**
   * The callback function to call when the button is no longer hovered over.
   */
  public var onOut:Void->Void;

  /**
   * Whether the button was just released.
   */
  public var justReleased(get, never):Bool;

  /**
   * Whether the button is currently released.
   */
  public var released(get, never):Bool;

  /**
   * Whether the button is currently pressed.
   */
  public var pressed(get, never):Bool;

  /**
   * Whether the button was just pressed.
   */
  public var justPressed(get, never):Bool;

  /**
   * The input associated with the button, using `Int` as the type.
   */
  var input:FlxInput<Int>;

  /**
   * The input currently pressing this button, if none, it's `null`.
   * Needed to check for its release.
   */
  var currentInput:IFlxInput;

  /**
   * Creates a new `FunkinButton` object with a gray background.
   *
   * @param X The x position of the button.
   * @param Y The y position of the button.
   * @param role The role of the button.
   */
  public function new(X:Float = 0, Y:Float = 0, role:FunkinButtonRole):Void
  {
    super(X, Y);

    status = FunkinButtonStatus.NORMAL;

    scrollFactor.set();

    input = new FlxInput(0);

    this.role = role;
  }

  /**
   * Called by the game state when the state is changed (if this object belongs to the state).
   */
  public override function destroy():Void
  {
    onUp = null;
    onDown = null;
    onOver = null;
    onOut = null;
    currentInput = null;
    input = null;

    super.destroy();
  }

  /**
   * Called by the game loop automatically, handles touch over and click detection.
   */
  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    #if FLX_POINTER_INPUT
    // Update the button, but only if touches are enabled
    if (visible)
    {
      final overlapFound:Bool = checkTouchOverlap();

      if (currentInput != null && currentInput.justReleased && overlapFound) onUpHandler();

      if (status != FunkinButtonStatus.NORMAL && (!overlapFound || (currentInput != null && currentInput.justReleased))) onOutHandler();
    }
    #end

    input.update();
  }

  private function checkTouchOverlap():Bool
  {
    for (camera in cameras)
    {
      for (touch in FlxG.touches.list)
      {
        if (checkInput(touch, touch, touch.justPressedPosition, camera)) return true;
      }
    }

    return false;
  }

  private function checkInput(pointer:FlxPointer, input:IFlxInput, justPressedPosition:FlxPoint, camera:FlxCamera):Bool
  {
    if (overlapsPoint(pointer.getWorldPosition(camera, _point), true, camera))
    {
      updateStatus(input);

      return true;
    }

    return false;
  }

  private function updateStatus(input:IFlxInput):Void
  {
    if (input.justPressed)
    {
      currentInput = input;

      onDownHandler();
    }
    else if (status == FunkinButtonStatus.NORMAL)
    {
      if (input.pressed)
      {
        onDownHandler();
      }
      else
      {
        onOverHandler();
      }
    }
  }

  private function onUpHandler():Void
  {
    status = FunkinButtonStatus.NORMAL;

    input.release();

    currentInput = null;

    if (onUp != null) onUp();
  }

  private function onDownHandler():Void
  {
    status = FunkinButtonStatus.PRESSED;

    input.press();

    if (onDown != null) onDown();
  }

  private function onOverHandler():Void
  {
    status = FunkinButtonStatus.PRESSED;

    if (onOver != null) onOver();
  }

  private function onOutHandler():Void
  {
    status = FunkinButtonStatus.NORMAL;

    input.release();

    if (onOut != null) onOut();
  }

  private inline function get_justReleased():Bool
  {
    return input.justReleased;
  }

  private inline function get_released():Bool
  {
    return input.released;
  }

  private inline function get_pressed():Bool
  {
    return input.pressed;
  }

  private inline function get_justPressed():Bool
  {
    return input.justPressed;
  }
}
