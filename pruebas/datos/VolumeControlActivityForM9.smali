.class public Lcom/android/systemui/fiio/volume/VolumeControlActivityForM9;
.super Landroid/app/Activity;
.source "VolumeControlActivityForM9.java"


# static fields
.field private static final TAG:Ljava/lang/String;

.field private static mKeyCount:I


# direct methods
.method public constructor <init>()V
    .registers 1

    .prologue
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    return-void
.end method


# virtual methods
.method public onKeyDown(ILandroid/view/KeyEvent;)Z
    .registers 9
    .param p1, "keyCode"    # I
    .param p2, "event"    # Landroid/view/KeyEvent;

    .prologue
    const/4 v5, 0x2

    const/4 v4, 0x1

    const/4 v3, 0x0

    invoke-super {p0, p1, p2}, Landroid/app/Activity;->onKeyDown(ILandroid/view/KeyEvent;)Z

    move-result v0

    return v0
.end method
