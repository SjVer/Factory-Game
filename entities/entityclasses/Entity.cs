using Godot;
using System;
using System.Linq;
using Godot.Collections;
using System.IO;

/// <summary>Base class for all entities</summary>
public class Entity : StaticBody2D
{
    // ===================== VARIABLES =====================

    protected bool Configured;
    protected bool Initialized;

    // rotation stuff
    public enum RotationMode
    {
        UP,
        RIGHT,
        DOWN,
        LEFT
    }
    public new RotationMode Rotation;
    protected Dictionary RotationData;

    protected TileMap ParentTileMap;

    protected AnimatedSprite AnimatedSprite = new AnimatedSprite();
    protected string SpriteSheetPathFormat;
    protected int[] SpriteCount;

    public int Frame
    {
        set { AnimatedSprite.Frame = value; }
        get { return AnimatedSprite.Frame; }
    }
    public bool SyncAnimation;

    public Vector2 Coordinates
    {
        set {
            if (!Initialized) WError("Cannot set Coordinates of uninitialized Entity"); 
            else Position = (ParentTileMap.MapToWorld(value) + ParentTileMap.CellSize / 2f) * ParentTileMap.Scale;
        }
        get {
            if (!Initialized) { WError("Cannot set Coordinates of uninitialized Entity"); return new Vector2(0, 0); }
            return ParentTileMap.WorldToMap(Position / ParentTileMap.Scale - ParentTileMap.CellSize / 2f);
        }
    }

    // ===================== CONFIGS =====================

    public void ConfigSimpleEntity(string spritePathFormat)
    {
        SpriteSheetPathFormat = spritePathFormat;
        SpriteCount = new int[2] { 1, 1 };

        Config();
    }

    public void ConfigAnimatedEntity(string spriteSheetPathFormat, int[] spriteCount, float speed, bool synced = true)
    {
        // assert that spriteCount's length is 2
        if (spriteCount.Length != 2) WError("Invalid spriteCount dimensions, expected an array of 2 integers");

        SpriteSheetPathFormat = spriteSheetPathFormat;
        SpriteCount = spriteCount;
        SyncAnimation = synced;
        AnimatedSprite.SpeedScale = speed;
        AnimatedSprite.Playing = true;

        Config();
    }

    // ===================== FUNCTIONS =====================

    public void Config()
    {
        // get rotation data
        RotationData = (Dictionary)((Dictionary)JSON.Parse(System.IO.File.ReadAllText("entities/entityclasses/rotations.json")).Result)[GetType().Name];
        Enum.TryParse<RotationMode>((string)RotationData["default"], out Rotation);

        SetCorrectSpriteSheet();
        Configured = true;
    }

    public void Init(TileMap map)
    {
        ParentTileMap = map;
        Scale = ParentTileMap.Scale;
        Name = GetType().Name;

        Initialized = true;
    }

    public override void _Ready()
    {
        if (!Configured) WError("Entity not configured", false);
        if (!Initialized) WError("Entity not initialized");

        AddChild(AnimatedSprite);
        //AddChild(CollisionShape2D);

        AddToGroup(GetType().Name);
    }

    public override void _PhysicsProcess(float delta)
    {
        if (SyncAnimation)
            AnimatedSprite.Frame = ((Entity)GetTree().GetNodesInGroup(GetType().Name)[0]).Frame;
    }

    public void SetCorrectSpriteSheet()
    {
        string fullPath = SpriteSheetPathFormat;
        switch(Rotation)
        {
            case RotationMode.UP: fullPath = String.Format(fullPath, 'u'); break;
            case RotationMode.RIGHT: fullPath = String.Format(fullPath, 'r'); break;
            case RotationMode.DOWN: fullPath = String.Format(fullPath, 'd'); break;
            case RotationMode.LEFT: fullPath = String.Format(fullPath, 'l'); break;

            default: WError($"Invalid rotation {Rotation}."); break;
        }

        StreamTexture streamText = GD.Load<StreamTexture>(fullPath);
        AnimatedSprite.Frames = new SpriteFrames();

        // first splice the streamText up as per the spriteCount using AtlasTextures
        float width  = (float)streamText.GetWidth()  / SpriteCount[0];
        float height = (float)streamText.GetHeight() / SpriteCount[1];

        int index = 0;
        for(int y = 0; y < SpriteCount[1]; y++)
            for(int x = 0; x < SpriteCount[0]; x++)
            {
                AtlasTexture atlas = new AtlasTexture
                {
                    Atlas = streamText,
                    Region = new Rect2
                    {
                        Position = new Vector2(x * width, y * height),
                        Size = new Vector2(width, height)
                    }
                };
                AnimatedSprite.Frames.AddFrame("default", atlas, index);
                index++;
            }

        AnimatedSprite.Frames.SetAnimationLoop("default", true);
        //frames.SetAnimationSpeed("default", fps);
    }

    public void Delete()
    {
        QueueFree();
    }

    public void Rotate(bool right)
    {
        RotationMode max = Enum.GetValues(typeof(RotationMode)).Cast<RotationMode>().Last();
        if (right) Rotation = Rotation + 1 > max ? 0 : Rotation + 1;
        else Rotation = Rotation - 1 < 0 ? max: Rotation - 1;

        if (((Godot.Collections.Array)RotationData["disabled"]).Contains(Rotation.ToString()))
            Rotate(right);

        SetCorrectSpriteSheet();
    }

    public override string ToString()
    {
        return $"[{GetType().Name}:{GetInstanceId()}]";
    }

    protected void WError(string message, bool exception = true)
    {
        string function = (new System.Diagnostics.StackTrace()).GetFrame(1).GetMethod().Name;
        string detail = exception ? "thrown" : "warning";
        string msg = $"[{GetType().Name}:{GetInstanceId()}]:{function}(): {message} ({detail})";
        GD.PrintErr(msg);
        if(exception) throw new ApplicationException(msg);
    }
}
