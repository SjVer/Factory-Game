using Godot;
using System;
using System.Drawing;

/// <summary>Base class for all entities</summary>
public class Entity : StaticBody2D
{
    // ===================== VARIABLES =====================

    protected bool Configured = false;
    protected bool Initialized = false;

    private TileMap TileMap = new TileMap();
    private AnimatedSprite AnimatedSprite = new AnimatedSprite();
    private CollisionShape2D CollisionShape2D = new CollisionShape2D();

    public Shape2D CollisionShape
    {
        set { CollisionShape2D.Shape = value; }
        get { return CollisionShape2D.Shape; }
    }
    public SpriteFrames SpriteFrames
    {
        set { AnimatedSprite.Frames = value; }
        get { return AnimatedSprite.Frames; }
    }
    /// <summary>The coordinates in tilespace</summary>
    public Vector2 Coordinates
    {
        set { Position = (TileMap.MapToWorld(value) + TileMap.CellSize / 2f) * TileMap.Scale; }
        get { return TileMap.WorldToMap(Position / TileMap.Scale - TileMap.CellSize / 2f); }
    }

    // ===================== CONFIGS =====================

    public void ConfigSimpleEntity(Shape2D collider, string spritePath)
    {
        StreamTexture streamText = GD.Load<StreamTexture>(spritePath);
        SpriteFrames frames = new SpriteFrames();
        frames.AddAnimation("default");
        frames.AddFrame("default", streamText, 0);

        Config(collider, frames);
    }

    public void ConfigAnimatedEntity(Shape2D collider, string spriteSheetPath, int[] spriteCount, float fps)
    {
        // assert that spriteCount's length is 2
        if (spriteCount.Length != 2) Error("Invalid spriteCount dimensions, expected an array of 2 integers");

        StreamTexture streamText = GD.Load<StreamTexture>(spriteSheetPath);
        SpriteFrames frames = new SpriteFrames();
        frames.AddAnimation("default");

        // first splice the streamText up as per the spriteCount using AtlasTextures
        float width  = (float)streamText.GetWidth()  / spriteCount[0];
        float height = (float)streamText.GetHeight() / spriteCount[1];

        int index = 0;
        for(int y = 0; y < spriteCount[1]; y++)
            for(int x = 0; x < spriteCount[0]; x++)
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
                frames.AddFrame("default", atlas, index);
                index++;
            }

        frames.SetAnimationLoop("default", true);
        frames.SetAnimationSpeed("default", fps);
        AnimatedSprite.Playing = true;

        //ResourceSaver.Save("res://test.tres", frames);

        Config(collider, frames);
    }

    // ===================== FUNCTIONS =====================

    public void Config(Shape2D collider, SpriteFrames frames)
    {
        CollisionShape = collider;
        SpriteFrames = frames;
        Configured = true;
    }

    public void Init(TileMap map)
    {
        TileMap = map;
        Scale = TileMap.Scale;
        Initialized = true;
    }

    public override void _Ready()
    {
        if (!Configured) Error("Entity not configured", false);
        if (!Initialized) Error("Entity not initialized");

        AddChild(AnimatedSprite);
        AddChild(CollisionShape2D);
    }

    protected void Error(string message, bool exception = true)
    {
        string function = (new System.Diagnostics.StackTrace()).GetFrame(1).GetMethod().Name;
        string detail = exception ? "thrown" : "warning";
        string msg = $"[{this.GetType().Name}:{this.GetInstanceId()}]:{function}(): {message} ({detail})";
        GD.PrintErr(msg);
        if(exception) throw new ApplicationException(msg);
    }
}
