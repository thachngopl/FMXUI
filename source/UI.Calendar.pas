{*******************************************************}
{                                                       }
{       FMX UI ���������Ԫ                             }
{                                                       }
{       ��Ȩ���� (C) 2017 YangYxd                       }
{                                                       }
{*******************************************************}

unit UI.Calendar;

interface

uses
  UI.Base, UI.Utils, UI.Ani, UI.Standard, UI.Calendar.Data,
  FMX.Effects, FMX.Text, FMX.Pickers,
  {$IFDEF MSWINDOWS}Windows, UI.Debug, {$ENDIF}
  {$IFDEF MSWINDOWS} FMX.DateTimeCtrls, {$ENDIF}
  {$IFDEF MACOS}FMX.DateTimeCtrls, {$ENDIF}
  FMX.Objects, System.Math, System.Actions, System.DateUtils, FMX.Consts,
  System.TypInfo, FMX.Graphics, System.Generics.Collections, FMX.TextLayout,
  System.Classes, System.Types, System.UITypes, System.SysUtils, System.Math.Vectors,
  FMX.Types, FMX.StdCtrls, FMX.Platform, FMX.Controls, FMX.InertialMovement,
  FMX.Ani, FMX.StdActns;

const
  InvaludeDate = $FFFFFF0;
  BID_Today = $FFFFFF1;
  BID_Next = $FFFFFF2;
  BID_Up = $FFFFFF3;
  BID_Navigation = $FFFFFF4;
  BID_Clear = $FFFFFF5;

type
  /// <summary>
  /// ����ѡ��
  /// </summary>
  TCalendarOption = (
     coShowNavigation, {��ʾ����}
     coShowWeek, {��ʾ������}
     coShowBeforeAfter, {��ʾ���е����ڣ����ָ�����ڲ��ڱ�������ʾΪ��ɫ}
     coCalendarWeeks, {��ʾ����}
     coTodayHighlight, {��������}
     coShowTodayButton, {��ʾ���찴ť}
     coShowClearButton, {��ʾ�����ť}
     coShowLunar, {��ʾũ��}
     coShowTerm, {��ʾ��������Ҫ���� coShowLunar}
     coShowRowLines, {��ʾ����}
     coShowCosLines, {��ʾ����}
     coCosLinesOut, {������coShowCosLinesʱ�����ñ���ʱ������������������}
     coShowWeekLine, {����������������֮����ʾ�ָ���}
     coEllipseSelect {��Drawable��IsCircleΪTrueʱ��ѡ�кͽ���ı���������Բ}
  );
  TCalendarOptions = set of TCalendarOption;

  TCalendarWeekItem = (
    Week0, Week1, Week2, Week3, Week4, Week5, Week6
  );
  TCalendarWeeks = set of TCalendarWeekItem;

type
  /// <summary>
  /// ������ͼ����
  /// </summary>
  TCalendarViewType = (Days {��}, Months {��}, Years {��}, Decades {10��}, Centuries {100��});
  /// <summary>
  /// ���ڿ�ʼֵ
  /// </summary>
  TWeekStart = Integer;

const
  CDefaultCalendarOptions = [coShowWeek, coShowNavigation, coTodayHighlight];

type
  /// <summary>
  /// �������Խӿ�
  /// </summary>
  ICalendarLanguage = interface
    ['{16B861E6-87E7-4C50-9808-33D1C0CF249B}']
    function WeekStrList: TArray<string>;
    function MonthsStrList: TArray<string>;
    function DateToStr(const Value: TDate): string;
    function TodayStr: string;
    function ClearStr: string;
  end;

type
  /// <summary>
  /// �������� - ����
  /// </summary>
  [ComponentPlatformsAttribute(AllCurrentPlatforms)]
  TCalendarLanguage_CN = class(TComponent, ICalendarLanguage)
  public
    function WeekStrList: TArray<string>;
    function MonthsStrList: TArray<string>;
    function DateToStr(const Value: TDate): string;
    function TodayStr: string;
    function ClearStr: string;
  end;

  /// <summary>
  /// �������� - Ӣ��
  /// </summary>
  [ComponentPlatformsAttribute(AllCurrentPlatforms)]
  TCalendarLanguage_EN = class(TComponent, ICalendarLanguage)
  public
    function WeekStrList: TArray<string>;
    function MonthsStrList: TArray<string>;
    function DateToStr(const Value: TDate): string;
    function TodayStr: string;
    function ClearStr: string;
  end;

type
  /// <summary>
  /// ��ɫ����
  /// </summary>
  TCalendarColor = class(TPersistent)
  private
    FOnChanged: TNotifyEvent;

    FDefault: TAlphaColor;      // Ĭ��
    FHovered: TAlphaColor;      // Ĭ����ͣ
    FPressed: TAlphaColor;      // ����
    FToday: TAlphaColor;        // ����
    FTodayHot: TAlphaColor;     // ������ͣ
    FSelected: TAlphaColor;     // ѡ��
    FSelectedHot: TAlphaColor;  // ѡ����ͣ
    FEnabled: TAlphaColor;      // ��Ч
    FWeekend: TAlphaColor;      // ��ĩ
    FWeekendHot: TAlphaColor;   // ��ĩ��ͣ
    FOutMonth: TAlphaColor;     // �Ǳ���
    FOutMonthHot: TAlphaColor;  // �Ǳ�����ͣ
    FHighlight: TAlphaColor;    // ����

    FColorStoreState: Cardinal;
  protected
    function GetColorStoreState(const Index: Integer): Boolean;
    procedure SetColorStoreState(const Index: Integer; const Value: Boolean);
  private
    function ColorDefaultStored: Boolean;
    function ColorEnabledStored: Boolean;
    function ColorHoveredStored: Boolean;
    function ColorSelectedHotStored: Boolean;
    function ColorSelectedStored: Boolean;
    function ColorTodayHotStored: Boolean;
    function ColorTodayStored: Boolean;
    function ColorWeekendStored: Boolean;
    procedure SetDefault(const Value: TAlphaColor);
    procedure SetEnabled(const Value: TAlphaColor);
    procedure SetHovered(const Value: TAlphaColor);
    procedure SetSelected(const Value: TAlphaColor);
    procedure SetSelectedHot(const Value: TAlphaColor);
    procedure SetToday(const Value: TAlphaColor);
    procedure SetTodayHot(const Value: TAlphaColor);
    procedure SetWeekend(const Value: TAlphaColor);
    function ColorOutMonthHotStored: Boolean;
    function ColorOutMonthStored: Boolean;
    function ColorWeekendHotStored: Boolean;
    procedure SetOutMonth(const Value: TAlphaColor);
    procedure SetOutMonthHot(const Value: TAlphaColor);
    procedure SetWeekendHot(const Value: TAlphaColor);
    function ColorHighlightStored: Boolean;
    procedure SetHighlight(const Value: TAlphaColor);
    function ColorPressedStored: Boolean;
    procedure SetPressed(const Value: TAlphaColor);
  protected
    procedure DoChange(Sender: TObject);
  public
    constructor Create(const ADefaultColor: TAlphaColor = TAlphaColorRec.Black);
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    function GetColor(const Index: Integer): TAlphaColor; virtual;

    property DefaultChange: Boolean index 1 read GetColorStoreState write SetColorStoreState;
    property HoveredChange: Boolean index 2 read GetColorStoreState write SetColorStoreState;
    property TodayChange: Boolean index 3 read GetColorStoreState write SetColorStoreState;
    property TodayHotChange: Boolean index 4 read GetColorStoreState write SetColorStoreState;
    property SelectedChange: Boolean index 5 read GetColorStoreState write SetColorStoreState;
    property SelectedHotChange: Boolean index 6 read GetColorStoreState write SetColorStoreState;
    property EnabledChange: Boolean index 7 read GetColorStoreState write SetColorStoreState;
    property WeekendChange: Boolean index 8 read GetColorStoreState write SetColorStoreState;
    property WeekendHotChange: Boolean index 9 read GetColorStoreState write SetColorStoreState;
    property OutMonthChange: Boolean index 10 read GetColorStoreState write SetColorStoreState;
    property OutMonthHotChange: Boolean index 11 read GetColorStoreState write SetColorStoreState;
    property HighlightChange: Boolean index 12 read GetColorStoreState write SetColorStoreState;
    property PressedChange: Boolean index 13 read GetColorStoreState write SetColorStoreState;

    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  published
    property Default: TAlphaColor read FDefault write SetDefault stored ColorDefaultStored;
    property Pressed: TAlphaColor read FPressed write SetPressed stored ColorPressedStored;
    property Hovered: TAlphaColor read FHovered write SetHovered stored ColorHoveredStored;
    property Today: TAlphaColor read FToday write SetToday stored ColorTodayStored;
    property TodayHot: TAlphaColor read FTodayHot write SetTodayHot stored ColorTodayHotStored;
    property Selected: TAlphaColor read FSelected write SetSelected stored ColorSelectedStored;
    property SelectedHot: TAlphaColor read FSelectedHot write SetSelectedHot stored ColorSelectedHotStored;
    property Enabled: TAlphaColor read FEnabled write SetEnabled stored ColorEnabledStored;
    property Weekend: TAlphaColor read FWeekend write SetWeekend stored ColorWeekendStored;
    property WeekendHot: TAlphaColor read FWeekendHot write SetWeekendHot stored ColorWeekendHotStored;
    property OutMonth: TAlphaColor read FOutMonth write SetOutMonth stored ColorOutMonthStored;
    property OutMonthHot: TAlphaColor read FOutMonthHot write SetOutMonthHot stored ColorOutMonthHotStored;
    property Highlight: TAlphaColor read FHighlight write SetHighlight stored ColorHighlightStored;
  end;

  TCalendarLunarColor = class(TCalendarColor)
  private
    FTerm: TAlphaColor;          // ����
    FHoliday: TAlphaColor;       // ����
    FHolidayLunar: TAlphaColor;
    function ColorHolidayLunarStored: Boolean;
    function ColorHolidayStored: Boolean;
    function ColorTermStored: Boolean;
    procedure SetHoliday(const Value: TAlphaColor);
    procedure SetHolidayLunar(const Value: TAlphaColor);
    procedure SetTerm(const Value: TAlphaColor);  // ũ������
  public
    procedure Assign(Source: TPersistent); override;
    function GetColor(const Index: Integer): TAlphaColor; override;

    property TermChange: Boolean index 14 read GetColorStoreState write SetColorStoreState;
    property HolidayChange: Boolean index 15 read GetColorStoreState write SetColorStoreState;
    property HolidayLunarChange: Boolean index 16 read GetColorStoreState write SetColorStoreState;
  published
    property Term: TAlphaColor read FTerm write SetTerm stored ColorTermStored;
    property Holiday: TAlphaColor read FHoliday write SetHoliday stored ColorHolidayStored;
    property HolidayLunar: TAlphaColor read FHolidayLunar write SetHolidayLunar stored ColorHolidayLunarStored;
  end;

  TCalendarTextSettings = class(TTextSettingsBase)
  private
    FColor: TCalendarColor;
    procedure SetColor(const Value: TCalendarColor);
  protected
    procedure InitColor; virtual;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    function GetStateColor(const State: TViewState): TAlphaColor; override;
  published
    property Color: TCalendarColor read FColor write SetColor;
    property Font;
    property PrefixStyle;
    property Trimming;
    property Gravity default TLayoutGravity.Center;
  end;

  TCalendarLunarTextSettings = class(TCalendarTextSettings)
  protected
    procedure InitColor; override;
  end;

  /// <summary>
  /// �����ɻ��ƶ���
  /// </summary>
  TCalendarDrawable = class(TDrawableBase)
  private
    FIsCircle: Boolean;
    function GetValue(const Index: Integer): TViewBrush;
    procedure SetValue(const Index: Integer; const Value: TViewBrush);
    procedure SetIsCircle(const Value: Boolean);
  public
    procedure Assign(Source: TPersistent); override;
  published
    property XRadius;
    property YRadius;
    property Corners;
    property CornerType;
    property IsCircle: Boolean read FIsCircle write SetIsCircle default False;
    property ItemHovered: TViewBrush index 0 read GetValue write SetValue;
    property ItemToday: TViewBrush index 1 read GetValue write SetValue;
    property ItemTodayHot: TViewBrush index 2 read GetValue write SetValue;
    property ItemSelected: TViewBrush index 3 read GetValue write SetValue;
    property ItemSelectedHot: TViewBrush index 4 read GetValue write SetValue;
    property ItemHighlight: TViewBrush index 5 read GetValue write SetValue;
    property ItemWeekNav: TViewBrush index 6 read GetValue write SetValue;
  end;

type
  TCalendarDateItem = record
    Text: string;
    IsTerm: Boolean; // �Ƿ�Ϊ����
    IsHoliday: Boolean; // �Ƿ��ǽ���
    IsLunarHoliday: Boolean; // �Ƿ���ũ������
  end;

  PCalendarDrawState = ^TCalendarDrawState;
  TCalendarDrawState = record
    Left: PCalendarDrawState;
    Right: PCalendarDrawState;
    Value: TDate; // ����
    DayOfWeek: Integer; // ���µ�һ���������
    First: Integer;  // ��ǰ��ʾ�ĵ�һ��
    Last: Integer;   // ��ǰ��ʾ�����һ��
    Rows: Integer; // ��Ҫ��ʾ������
    RowHeight: Single; // ����ÿ�и߶�
    DrawS: Integer; // ��ǰ���Ƶĵ�һ��
    DrawSD: Integer; // ��ǰ���Ƶĵ�һ�������
    Weeks: Integer;  // ���µ�һ������������
    Month, Year: Word; // ��ǰѡ�����ڵ��꣬��
    XOffset: Single; // ����ʱ��Xƫ��
    LunarDataList: TArray<TCalendarDateItem>; // ũ������
    procedure ClearLunar;
    procedure Clear;
  end;

type
  TOnGetLunarData = procedure (Sender: TObject; const Date: TDate; var Text: TCalendarDateItem) of object;
  TOnOwnerDrawCalendar = procedure (Sender: TObject; Canvas: TCanvas; const R: TRectF; const Date: TDate; var DrawDefault: Boolean) of object;
  TOnClickView = procedure (Sender: TObject; const ID: Integer) of object;

type
  TCalendarViewBase = class(TView)
  private const
    CDefaultRowHeihgt = 45;
    CDefaultRowLunarHeight = 20;
    CDefaultWeeksWidth = 40;  // �����п��
    CDefaultDividerColor = $ffc0c0c0;
    CDefaultNextUpW = 30;
  private
    [Weak] FLanguage: ICalendarLanguage;
    [Weak] FInnerLanguage: ICalendarLanguage;
    FOptions: TCalendarOptions;
    FViewTypeStart: TCalendarViewType;
    FViewTypeMin: TCalendarViewType;
    FViewTypeMax: TCalendarViewType;
    FStartDate: TDate;
    FEndDate: TDate;
    FWeekStart: TWeekStart;
    FDaysOfWeekDisabled: TCalendarWeeks;
    FDaysOfWeekHighlighted: TCalendarWeeks;

    FTextSettings: TCalendarTextSettings;
    FTextSettingsOfLunar: TCalendarLunarTextSettings;
    FTextSettingsOfTitle: TSimpleTextSettings;
    FTextSettingsOfWeeks: TSimpleTextSettings;

    FDrawable: TCalendarDrawable;
    FDividerBrush: TBrush;

    FAniCalc: TAniCalculationsEx;
    FCanAniMove: Boolean;
    FStartScroll: Boolean;

    FRowPadding: Single;
    FRowHeihgt: Single;
    FRowLunarHeight: Single;
    FRowLunarPadding: Single;

    FWeeksWidth: Single;

    FDivider: TAlphaColor; // �ָ�����ɫ
    FInFitSize: Boolean;
    FAning: Integer;

    FRangeOfNavigation: TRectF;
    FRangeOfDays: TRectF;

    FOnValueChange: TNotifyEvent;
    FOnGetLunarData: TOnGetLunarData;
    FOnOwnerDrawCalendar: TOnOwnerDrawCalendar;
    FOnClickView: TOnClickView;

    procedure SetOptions(const Value: TCalendarOptions);
    procedure SetEndDate(const Value: TDate);
    procedure SetLanguage(const Value: ICalendarLanguage);
    procedure SetStartDate(const Value: TDate);
    procedure SetStartView(const Value: TCalendarViewType);
    procedure SetWeekStart(const Value: TWeekStart);
    function IsEndDateStored: Boolean;
    function IsStartDateStored: Boolean;
    function GetLanguage: ICalendarLanguage;
    procedure SetDaysOfWeekDisabled(const Value: TCalendarWeeks);
    procedure SetDaysOfWeekHighlighted(const Value: TCalendarWeeks);
    procedure SetTextSettings(const Value: TCalendarTextSettings);
    procedure SetTextSettingsOfLunar(const Value: TCalendarLunarTextSettings);
    procedure SetTextSettingsOfTitle(const Value: TSimpleTextSettings);
    procedure SetTextSettingsOfWeeks(const Value: TSimpleTextSettings);
    procedure SetDrawable(const Value: TCalendarDrawable);
    function GetAutoSize: Boolean;
    function IsStoredRowHeihgt: Boolean;
    function IsStoredRowLunarHeight: Boolean;
    function IsStoredRowLunarPadding: Boolean;
    function IsStoredRowPadding: Boolean;
    procedure SetAutoSize(const Value: Boolean);
    procedure SetRowHeihgt(const Value: Single);
    procedure SetRowLunarHeight(const Value: Single);
    procedure SetRowLunarPadding(const Value: Single);
    procedure SetRowPadding(const Value: Single);
    procedure SetValue(const Value: TDate);
    procedure SetDivider(const Value: TAlphaColor);
    function GetLunarData(const LDate: Integer; const AState: TCalendarDrawState): TCalendarDateItem;
    function GetHoverDate: TDate;
    function IsStoredWeeksWidth: Boolean;
    procedure SetWeeksWidth(const Value: Single);
    procedure SetCurViewType(const Value: TCalendarViewType);
    procedure SetViewTypeMax(const Value: TCalendarViewType);
    procedure SetViewTypeMin(const Value: TCalendarViewType);
    function GetValue: TDate;
    function GetAniX: Single;
    procedure SetAniX(const Value: Single);
    function GetMonthBegin: TDate;
    function GetMonthEnd: TDate;
  protected
    procedure AniCalcChange(Sender: TObject);
    procedure AniCalcStop(Sender: TObject);
    procedure UpdateScrollLimits(Flag: Integer = 0);
  protected
    FValue: TDate;
    FSelected: Boolean;

    FCurViewType: TCalendarViewType; // ��ǰ��ͼ����
    FCurHotDate: Integer; // ��ǰ���ָ�������
    FCurState: TCalendarDrawState;

    function IsAutoSize: Boolean; override;
    procedure DoOptionsChange; virtual;
    procedure DoChange; virtual;
    procedure DoTextSettingsChange(Sender: TObject);
    procedure DoDrawableChange(Sender: TObject);
    procedure DoDateChange(); virtual;

    procedure DoAutoSize;
    procedure InitDividerBrush;

    function CalcMonthOffset(Flag: Integer): Integer;

    procedure SwitchDate(const Value: TDate = InvaludeDate; const OffsetMonth: Integer = 0);
    procedure ParseValue(const Value: TDate; var AState: TCalendarDrawState); virtual;
    procedure ParseValueLunar(var AState: TCalendarDrawState); virtual;
    function IsInvalidValue(const Value: Integer): Boolean;
  protected
    procedure Loaded; override;
    procedure Resize; override;
    procedure DoRecalcSize(var AWidth, AHeight: Single); override;
    function GetDefaultSize: TSizeF; override;
    function GetNotDaysRowHeight(const RowCount: Integer): Single; virtual;

    function CanRePaintBk(const View: IView; State: TViewState): Boolean; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, y: single); override;

    procedure DoMouseLeave; override;
    procedure DoClickEvent; override;

    procedure PaintBackground; override;
    procedure PaintToCanvas(Canvas: TCanvas; const AState: TCalendarDrawState);

    procedure DoDrawNavigation(Canvas: TCanvas; const R: TRectF; const AState: TCalendarDrawState);
    procedure DoDrawWeekRow(Canvas: TCanvas; const R: TRectF; const AState: TCalendarDrawState);
    procedure DoDrawDatesRow(Canvas: TCanvas; var R: TRectF; WeekRowTop: Single; const AState: TCalendarDrawState);
    procedure DoDrawItemBackground(Canvas: TCanvas; ABrush: TBrush; const R: TRectF; IsCircle: Boolean);
    procedure DoDrawButton(Canvas: TCanvas; const R: TRectF; const Text: string; const ID: Integer);
    procedure DoDrawMonths(Canvas: TCanvas; const R: TRectF; const AState: TCalendarDrawState);
    procedure DoDrawYears(Canvas: TCanvas; const R: TRectF; const YearInterval: Integer; const AState: TCalendarDrawState);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Clear;
    procedure Today;

    /// <summary>
    /// �Ƿ��Ѿ�ѡ����һ������
    /// </summary>
    property IsSelected: Boolean read FSelected;

    /// <summary>
    /// ��ǰָ�������
    /// </summary>
    property HoverDate: TDate read GetHoverDate;
    /// <summary>
    /// ��ǰ��ͼ����
    /// </summary>
    property ViewType: TCalendarViewType read FCurViewType write SetCurViewType;

    /// <summary>
    /// �Զ���С
    /// </summary>
    property AutoSize: Boolean read GetAutoSize write SetAutoSize default False;

    /// <summary>
    /// �ָ�����ɫ
    /// </summary>
    property Divider: TAlphaColor read FDivider write SetDivider default CDefaultDividerColor;

    /// <summary>
    /// ��������
    /// </summary>
    property TextSettings: TCalendarTextSettings read FTextSettings write SetTextSettings;
    /// <summary>
    /// �������� - ũ���ͽ���
    /// </summary>
    property TextSettingsOfLunar: TCalendarLunarTextSettings read FTextSettingsOfLunar write SetTextSettingsOfLunar;
    /// <summary>
    /// �������� - �������ں͵�����ť
    /// </summary>
    property TextSettingsOfTitle: TSimpleTextSettings read FTextSettingsOfTitle write SetTextSettingsOfTitle;
    /// <summary>
    /// �������� - ����
    /// </summary>
    property TextSettingsOfWeeks: TSimpleTextSettings read FTextSettingsOfWeeks write SetTextSettingsOfWeeks;

    /// <summary>
    /// ���Ʊ���ɫ
    /// </summary>
    property Drawable: TCalendarDrawable read FDrawable write SetDrawable;

    /// <summary>
    /// ��ǰѡ��ʱ��
    /// </summary>
    property DateTime: TDate read GetValue write SetValue;

    property MonthBegin: TDate read GetMonthBegin;
    property MonthEnd: TDate read GetMonthEnd;

    property AniX: Single read GetAniX write SetAniX;

    /// <summary>
    /// ѡ��
    /// </summary>
    property Options: TCalendarOptions read FOptions write SetOptions;
    /// <summary>
    /// ��ʼʱ��ʾ����ͼ����
    /// </summary>
    property ViewModeStart: TCalendarViewType read FViewTypeStart write SetStartView;
    /// <summary>
    /// ��С��ͼ����
    /// </summary>
    property ViewModeMin: TCalendarViewType read FViewTypeMin write SetViewTypeMin;
    /// <summary>
    /// �����ͼ����
    /// </summary>
    property ViewModeMax: TCalendarViewType read FViewTypeMax write SetViewTypeMax;
    /// <summary>
    /// �޶��Ŀ�ʼ����
    /// </summary>
    property StartDate: TDate read FStartDate write SetStartDate stored IsStartDateStored;
    /// <summary>
    /// �޶��Ľ�������
    /// </summary>
    property EndDate: TDate read FEndDate write SetEndDate stored IsEndDateStored;
    /// <summary>
    /// ������ʾ�����ڼ���ʼ��Ĭ��Ϊ0���������쿪ʼ
    /// </summary>
    property WeekStart: TWeekStart read FWeekStart write SetWeekStart;
    /// <summary>
    /// ���Խӿ�
    /// </summary>
    property Language: ICalendarLanguage read GetLanguage write SetLanguage;


    /// <summary>
    /// ��ֹѡ������������ڼ�
    /// </summary>
    property DaysOfWeekDisabled: TCalendarWeeks read FDaysOfWeekDisabled write SetDaysOfWeekDisabled default [];
    /// <summary>
    /// ������ʾ�����������ڼ�
    /// </summary>
    property DaysOfWeekHighlighted: TCalendarWeeks read FDaysOfWeekHighlighted write SetDaysOfWeekHighlighted default [];


    /// <summary>
    /// �м��
    /// </summary>
    property RowPadding: Single read FRowPadding write SetRowPadding stored IsStoredRowPadding;
    /// <summary>
    /// �и�
    /// </summary>
    property RowHeight: Single read FRowHeihgt write SetRowHeihgt stored IsStoredRowHeihgt;
    /// <summary>
    /// ũ���ͽ����и�
    /// </summary>
    property RowLunarHeight: Single read FRowLunarHeight write SetRowLunarHeight stored IsStoredRowLunarHeight;
    /// <summary>
    /// ũ���ͽ���������֮��ļ��
    /// </summary>
    property RowLunarPadding: Single read FRowLunarPadding write SetRowLunarPadding stored IsStoredRowLunarPadding;

    /// <summary>
    /// �����п��
    /// </summary>
    property WeeksWidth: Single read FWeeksWidth write SetWeeksWidth stored IsStoredWeeksWidth;

    /// <summary>
    /// ѡ������ڸı�
    /// </summary>
    property OnChange: TNotifyEvent read FOnValueChange write FOnValueChange;
    /// <summary>
    /// ��ȡũ������
    /// </summary>
    property OnOwnerLunarData: TOnGetLunarData read FOnGetLunarData write FOnGetLunarData;
    /// <summary>
    /// �Ի�����
    /// </summary>
    property OnOwnerDrawCalendar: TOnOwnerDrawCalendar read FOnOwnerDrawCalendar write FOnOwnerDrawCalendar;
    /// <summary>
    /// ����¼�
    /// </summary>
    property OnClickView: TOnClickView read FOnClickView write FOnClickView;
  published
    property EnableExecuteAction default True;
    property CanFocus default True;
    property Clickable default True;
  end;

type
  /// <summary>
  /// ����ʱ����ʾ��� ����л�� ��������
  /// </summary>
  TCustomDateTimeView = class(TTextView)
  strict private
  private
    FDateTime: TDateTime;
    FDateTimeFormat: string;
    function GetDateTime: TDateTime;
    procedure SetDateTime(const Value: TDateTime);
  protected
    {$IFDEF NEXTGEN}
    FDateTimePicker: TCustomDateTimePicker;
    {$ELSE}
    [Weak] FLanguage: ICalendarLanguage;
    FDateTimePicker: TCalendarViewBase;
    FIsShow: Boolean;
    procedure DoDateChange(Sender: TObject);
    procedure DoClickDateTimeView(Sender: TObject; const ID: Integer);
    {$ENDIF}
    procedure HandlerPickerClosed(Sender: TObject);
    procedure HandlerPickerOpened(Sender: TObject);
    procedure HandlerPickerDateTimeChanged(Sender: TObject; const ADate: TDateTime);
    procedure InitPicker; virtual;
    procedure Click; override;
    function IsShow(): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {Pickers}
    procedure OpenPicker; virtual;
    procedure ClosePicker; virtual;
    function IsPickerOpened: Boolean; virtual;
    function HasPicker: Boolean;
    {Value}
    property DateTime: TDateTime read GetDateTime write SetDateTime;
  published
    property DateTimeFormat: string read FDateTimeFormat write FDateTimeFormat;

    property CanFocus default True;
    property HitTest default True;
    property Clickable default True;
  end;

type
  /// <summary>
  /// ������ͼ (����ѡ��)
  /// </summary>
  [ComponentPlatformsAttribute(AllCurrentPlatforms)]
  TDateView = class(TCustomDateTimeView)
  private
    function GetLanguage: ICalendarLanguage;
    procedure SetLanguage(const Value: ICalendarLanguage);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Language: ICalendarLanguage read GetLanguage write SetLanguage;
  end;

type
  /// <summary>
  /// ʱ����ͼ (����ʱ��ѡ��Ի���)
  /// </summary>
  [ComponentPlatformsAttribute(AllCurrentPlatforms)]
  TTimeView = class(TCustomDateTimeView)
  protected
  public
    constructor Create(AOwner: TComponent); override;
    {$IFNDEF NEXTGEN}
    procedure DoTimeChange(Sender: TObject);
    procedure OpenPicker; override;
    procedure ClosePicker; override;
    {$ENDIF}
  end;

type
  /// <summary>
  /// ������ͼ���
  /// </summary>
  [ComponentPlatformsAttribute(AllCurrentPlatforms)]
  TCalendarView = class(TCalendarViewBase)
  published
    property CanFocus default True;
    property HitTest default True;
    property Clickable default True;

    property AutoSize;
    property Options default CDefaultCalendarOptions;
    property ViewModeStart default TCalendarViewType.Days;
    property ViewModeMin default TCalendarViewType.Days;
    property ViewModeMax default TCalendarViewType.Years;
    property StartDate;
    property EndDate;
    property WeekStart default 0;
    property WeeksWidth;
    property Language;
    property DaysOfWeekDisabled;
    property DaysOfWeekHighlighted;

    property Divider;
    property Drawable;
    property DateTime;

    property RowPadding;
    property RowHeight;
    property RowLunarHeight;
    property RowLunarPadding;

    property TextSettings;
    property TextSettingsOfLunar;
    property TextSettingsOfTitle;
    property TextSettingsOfWeeks;

    property OnChange;
    property OnOwnerLunarData;
    property OnOwnerDrawCalendar;
    property OnClickView;
  end;

implementation

uses
  FMX.Forms, UI.Dialog, UI.Frame;

type
  TTmpSimpleTextSettings = class(TSimpleTextSettings);

var
  DefaultLanguage: TCalendarLanguage_EN;
  FDownTime: Int64 = 0;
  FDownX: Single = 0;

procedure DecodeDate(const DateTime: TDateTime; var Year, Month, Day: Word);
var
  Dummy: Word;
begin
  DecodeDateFully(DateTime, Year, Month, Day, Dummy);
end;

function IncMonth(const V: TDateTime; IncM: Integer; First: Boolean = True): TDateTime;
var
  Y, M, D, D2: Word;
begin
  if IncM <> 0 then begin
    DecodeDate(V, Y, M, D);
    Y := Y + (IncM div 12);
    M := M + (IncM mod 12);
    while M > 12 do begin
      Inc(Y);
      Dec(M, 12);
    end;
    while M < 1 do begin
      Dec(Y);
      Inc(M, 12);
    end;
    if First then
      D := 1;
    if D > 28 then begin
      D2 := DaysInMonth(EncodeDate(Y, M, 1));
      if D > D2 then
        D := D2;
    end;
    if Y < 1 then Y := 1;
    if Y > 9999 then Y := 9999;
    Result := EncodeDate(Y, M, D);
  end else
    Result := V;
end;

function GetVolecity(X: Single): Single;
var
  T: Int64;
begin
  T := GetTimestamp - FDownTime;
  Result := Abs(X - FDownX);
  if T > 1 then
    Result := Result / T * 100;
  //OutputDebugString(PChar(FloatToStr(Result)));
end;

{ TCalendarLanguage_CN }

function TCalendarLanguage_CN.ClearStr: string;
begin
  Result := '���';
end;

function TCalendarLanguage_CN.DateToStr(const Value: TDate): string;
begin
  Result := FormatDateTime('yyyy��mm��', Value);
end;

function TCalendarLanguage_CN.MonthsStrList: TArray<string>;
begin
  Result := ['1��', '2��', '3��', '4��', '5��', '6��',
    '7��', '8��', '9��', '10��', '11��', '12��'];
end;

function TCalendarLanguage_CN.TodayStr: string;
begin
  Result := '����';
end;

function TCalendarLanguage_CN.WeekStrList: TArray<string>;
begin
  Result := ['��', 'һ', '��', '��', '��', '��', '��'];
end;

{ TCalendarLanguage_EN }

function TCalendarLanguage_EN.ClearStr: string;
begin
  Result := 'Clear';
end;

function TCalendarLanguage_EN.DateToStr(const Value: TDate): string;
const
  LMonths: array [0..11] of string = (
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December');
var
  Y, M, D: Word;
begin
  DecodeDate(Value, Y, M, D);
  Result := Format('%s %d', [LMonths[M - 1], Y]);
end;

function TCalendarLanguage_EN.MonthsStrList: TArray<string>;
begin
  Result := ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
end;

function TCalendarLanguage_EN.TodayStr: string;
begin
  Result := 'Today';
end;

function TCalendarLanguage_EN.WeekStrList: TArray<string>;
begin
  Result := ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
end;

{ TCalendarViewBase }

procedure TCalendarViewBase.AniCalcChange(Sender: TObject);
begin
  InvalidateRect(ClipRect);
end;

procedure TCalendarViewBase.AniCalcStop(Sender: TObject);
begin
  if Scene <> nil then
    Scene.ChangeScrollingState(nil, False);
  if FAning <> 0 then begin
    FAniCalc.BoundsAnimation := True;
    FAniCalc.ViewportPositionF := PointF(0, 0);
    FAniCalc.UpdatePosImmediately(True);
    FAniCalc.TouchTracking := [ttHorizontal];
    FCurHotDate := FAning;
    FAning := 0;
    DoClickEvent;
    FCurHotDate := InvaludeDate;
  end;
end;

function TCalendarViewBase.CalcMonthOffset(Flag: Integer): Integer;
begin
  case FCurViewType of
    TCalendarViewType.Days: Result := -1;
    TCalendarViewType.Months: Result := -12;
    TCalendarViewType.Years: Result := -120;
    TCalendarViewType.Decades: Result := -1200;
    TCalendarViewType.Centuries: Result := -12000;
  else
    Result := 0;
  end;
  if Flag <> 0 then
    Result := -Result;
end;

function TCalendarViewBase.CanRePaintBk(const View: IView;
  State: TViewState): Boolean;
begin
  Result := (FTextSettings.FColor.FPressed <> 0) or inherited;
end;

procedure TCalendarViewBase.Clear;
begin
  FSelected := False;
  DoDateChange;
end;

constructor TCalendarViewBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCurState.Left := nil;
  FCurState.Right := nil;
  FCurState.Clear;
  FLanguage := nil;
  FInnerLanguage := nil;
  FOptions := CDefaultCalendarOptions;
  FViewTypeMax := TCalendarViewType.Years;

  FTextSettings := TCalendarTextSettings.Create(Self);
  FTextSettingsOfLunar := TCalendarLunarTextSettings.Create(Self);
  FTextSettingsOfTitle := TSimpleTextSettings.Create(Self);
  FTextSettingsOfWeeks := TSimpleTextSettings.Create(Self);

  FTextSettingsOfLunar.FColor.FDefault := $ff606060;
  FTextSettingsOfLunar.FColor.FColorStoreState := 0;

  FDrawable := TCalendarDrawable.Create(Self);
  FDrawable.ItemToday.ChangeToSolidColor($ffffdb99);
  FDrawable.ItemSelected.ChangeToSolidColor($ff286090);
  FDrawable.ItemHovered.ChangeToSolidColor($fff5f5f5);
  FDrawable.ItemTodayHot.ChangeToSolidColor($ffffc966);
  FDrawable.ItemSelectedHot.ChangeToSolidColor($ff204d74);
  FDrawable.ItemHighlight.ChangeToSolidColor($bfd9edf7);

  FRowPadding := 0;
  FRowHeihgt := CDefaultRowHeihgt;
  FRowLunarHeight := CDefaultRowLunarHeight;
  FRowLunarPadding := 0;
  FWeeksWidth := CDefaultWeeksWidth;

  FDivider := CDefaultDividerColor;

  FAniCalc := TAniCalculationsEx.Create(nil);
  FAniCalc.ViewportPositionF := PointF(0, 0);
  FAniCalc.Animation := True;
  FAniCalc.Averaging := True;
  FAniCalc.Interval := 8;
  FAniCalc.BoundsAnimation := True;
  FAniCalc.TouchTracking := [ttHorizontal];
  FAniCalc.OnChanged := AniCalcChange;

  EnableExecuteAction := True;
  SetAcceptsControls(False);
  Clickable := True;
  CanFocus := True;
end;

destructor TCalendarViewBase.Destroy;
begin
  FInnerLanguage := nil;
  FLanguage := nil;
  FCurState.Clear;
  FreeAndNil(FTextSettings);
  FreeAndNil(FTextSettingsOfLunar);
  FreeAndNil(FTextSettingsOfTitle);
  FreeAndNil(FTextSettingsOfWeeks);
  FreeAndNil(FDrawable);
  FreeAndNil(FDividerBrush);
  FreeAndNil(FAniCalc);
  inherited Destroy;
end;

procedure TCalendarViewBase.DoAutoSize;
var
  W, H: Single;
begin
  if FInFitSize or (not FAdjustViewBounds) or (csLoading in ComponentState) then
    Exit;
  if TextSettings.WordWrap then begin // ֻ����Ҫ�Զ�����ʱ������Ҫ�жϸ�������Ŀ��
    W := GetParentMaxWidth;
    H := GetParentMaxHeight;
  end else begin
    W := 0;
    H := 0;
  end;
  if (MaxHeight > 0) and (W > MaxWidth) then
    W := MaxWidth;
  if (MaxHeight > 0) and (H > MaxHeight) then
    H := MaxHeight;
  if W <= 0 then
    W := FSize.Width;
  if H <= 0 then
    H := FSize.Height;
  DoChangeSize(W, H);
  if (W <> FSize.Width) or (H <> FSize.Height) then begin
    FInFitSize := True;
    SetSize(W, H, False);
    FInFitSize := False;
  end;
end;

procedure TCalendarViewBase.DoChange;
begin
  Invalidate;
end;

procedure TCalendarViewBase.DoClickEvent;
begin
  if (csDesigning in ComponentState) then
    Exit;
  case FCurHotDate of
    InvaludeDate:
      Exit;
    BID_Up:
      begin
        SwitchDate(InvaludeDate, CalcMonthOffset(0));
      end;
    BID_Next:
      begin
        SwitchDate(InvaludeDate, CalcMonthOffset(1));
      end;
    BID_Today:
      begin
        DateTime := Now;
        if Assigned(FOnClickView) then FOnClickView(Self, FCurHotDate);
      end;
    BID_Navigation:
      begin
        case FCurViewType of
          TCalendarViewType.Days: Viewtype := TCalendarViewType.Months;
          TCalendarViewType.Months: Viewtype := TCalendarViewType.Years;
          TCalendarViewType.Years: Viewtype := TCalendarViewType.Decades;
          TCalendarViewType.Decades: Viewtype := TCalendarViewType.Centuries;
        end;
      end;
    BID_Clear:
      begin
        Clear;
        if Assigned(FOnClickView) then FOnClickView(Self, FCurHotDate);
      end
  else
    begin
      if Assigned(FAniCalc) and (Abs(FAniCalc.ViewportPosition.X) > 1) then
        Exit;
      case FCurViewType of
        Days:
          begin
            DateTime := HoverDate;
            if Assigned(FOnClickView) then
              FOnClickView(Self, FCurHotDate);
            Exit;
          end;
        Months:
          begin
            FSelected := True;
            SwitchDate(FValue, FCurHotDate - FCurState.Month);
          end;
        Years:
          begin
            FSelected := True;
            SwitchDate(FValue, ((FCurState.Year div 10 * 10 + FCurHotDate - 2) - FCurState.Year) * 12);
          end;
        Decades:
          begin
            FSelected := True;
            SwitchDate(FValue, ((FCurState.Year div 100 * 100 + FCurHotDate * 10 - 20) - FCurState.Year) * 12);
          end;
        Centuries:
          begin
            FSelected := True;
            SwitchDate(FValue, ((FCurState.Year div 1000 * 1000 + FCurHotDate * 100 - 200) - FCurState.Year) * 12);
          end;
      end;
      if Assigned(FOnClickView) then FOnClickView(Self, FCurHotDate);
      Viewtype := TCalendarViewType(Ord(Viewtype) - 1);
    end;
  end;
end;

procedure TCalendarViewBase.DoDateChange;
begin
  DoChange;
  if Assigned(FOnValueChange) then
    FOnValueChange(Self);
end;

procedure TCalendarViewBase.DoDrawableChange(Sender: TObject);
begin
  if IsAutoSize and (csDesigning in ComponentState) then begin
    DoAutoSize;
  end else
    DoChange;
end;

procedure TCalendarViewBase.DoDrawButton(Canvas: TCanvas; const R: TRectF;
  const Text: string; const ID: Integer);
var
  LColor: TAlphaColor;
begin
  LColor := FTextSettingsOfTitle.Color;
  if FCurHotDate = ID then begin
    DoDrawItemBackground(Canvas, FDrawable.FDefault, R, False);
    if (DrawState = TViewState.Pressed) and (FTextSettings.FColor.FPressed <> 0) then
      TTmpSimpleTextSettings(FTextSettingsOfTitle).FColor := FTextSettings.FColor.FPressed
    else if FTextSettings.FColor.FHovered <> 0 then
      TTmpSimpleTextSettings(FTextSettingsOfTitle).FColor := FTextSettings.FColor.FHovered;
  end;
  FTextSettingsOfTitle.Draw(Canvas, Text, R, Opacity, TViewState.None, TLayoutGravity.Center);
  TTmpSimpleTextSettings(FTextSettingsOfTitle).FColor := LColor;
end;

procedure TCalendarViewBase.DoDrawDatesRow(Canvas: TCanvas; var R: TRectF; WeekRowTop: Single;
  const AState: TCalendarDrawState);
var
  X, Y, W, LX, LY, LunarHeight, LOpacity: Single;
  S, LS, LE, LSelect, LToday, Week, ColorIndex, LES, LEE: Integer;
  I, J, D, L: Integer;
  Lunar, BeforeAfter, IsEnd, IsDrawDefault: Boolean;
  LColor: TAlphaColor;
  LR: TRectF;
  LItem: TCalendarDateItem;
begin
  W := R.Width + 1; // ��Ϊ������ʱ���Ὣÿ���ȼ�1�������ܿ��+1
  LX := R.Left;
  Y := R.Top;
  if coCalendarWeeks in FOptions then begin
    W := W - FWeeksWidth;
    LX := LX + FWeeksWidth;
  end;
  W := W / 7;

  if coShowLunar in FOptions then
    LunarHeight := FRowLunarHeight + Max(0, FRowLunarPadding)
  else
    LunarHeight := 0;

  LS := AState.First;
  LE := AState.Last;
  S := AState.DrawS;
  D := AState.DrawSD;
  LES := Trunc(FStartDate);
  LEE := Trunc(FEndDate);

  if FSelected then
    LSelect := Trunc(AState.Value)
  else
    LSelect := InvaludeDate;
  LToday := Trunc(Now);
  LOpacity := Opacity;

  BeforeAfter := coShowBeforeAfter in FOptions;
  Lunar := coShowLunar in FOptions;

  if (coShowRowLines in FOptions) then begin
    L := 1;
  end else
    L := 0;

  if Assigned(FDividerBrush) then
    FDividerBrush.Color := FDivider
  else
    L := 0;

  IsEnd := False;

  // ������
  if (coCalendarWeeks in FOptions) and (FTextSettingsOfWeeks.Color and $FF000000 <> 0) then begin
    LY := Y;
    for J := 1 to AState.Rows do begin
      FTextSettingsOfWeeks.FillText(Canvas, RectF(R.Left, LY, LX, LY + FRowHeihgt + LunarHeight),
          IntToStr(AState.Weeks + J - 1), LOpacity, FTextSettingsOfWeeks.Color,
          FTextSettingsOfWeeks.FillTextFlags, nil, 0, TTextAlign.Center);
      LY := LY + FRowHeihgt + FRowPadding + LunarHeight;
    end;
  end;

  for J := 1 to AState.Rows do begin
    X := LX;
    for I := 0 to 6 do begin
      if BeforeAfter or ((S >= LS) and (S <= LE)) then begin

        LR := RectF(X, Y, X + W - 1, Y + FRowHeihgt + LunarHeight);

        if Assigned(FOnOwnerDrawCalendar) then begin
          // �Ի�
          IsDrawDefault := False;
          FOnOwnerDrawCalendar(Self, Canvas, LR, S, IsDrawDefault);
        end else
          IsDrawDefault := True;

        if IsDrawDefault then begin

          Week := (I + FWeekStart) mod 7;
          LColor := 0;
          ColorIndex := 0;

          // ������ʾ����
          if (TCalendarWeekItem(Week) in DaysOfWeekHighlighted) and Assigned(FDrawable.FChecked) then
            FDrawable.FillRect(Canvas, LR, 0, 0, FDrawable.Corners, LOpacity, FDrawable.FChecked);

          // ������
          if (TCalendarWeekItem(Week) in DaysOfWeekDisabled) or
            ((LES <> 0) and (S < LES)) or ((LEE <> 0) and (S > LEE))
          then begin  // ��ֹѡ��
            LColor := FTextSettings.FColor.FEnabled;
            ColorIndex := 7;
          end else if S = LSelect then begin  // ѡ��
            if (FCurHotDate = S) then begin
              DoDrawItemBackground(Canvas, FDrawable.FHovered, LR, FDrawable.IsCircle);
              LColor := FTextSettings.FColor.FSelectedHot;
              ColorIndex := 6;
            end else begin
              DoDrawItemBackground(Canvas, FDrawable.FSelected,  LR, FDrawable.IsCircle);
              LColor := FTextSettings.FColor.FSelected;
              ColorIndex := 5;
            end;
          end else if (S = LToday) and (coTodayHighlight in FOptions) then begin // ����
            if (FCurHotDate = S) then begin
              DoDrawItemBackground(Canvas, FDrawable.FFocused, LR, FDrawable.IsCircle);
              LColor := FTextSettings.FColor.FTodayHot;
              ColorIndex := 4;
            end else begin
              DoDrawItemBackground(Canvas, FDrawable.FPressed, LR, FDrawable.IsCircle);
              LColor := FTextSettings.FColor.FToday;
              ColorIndex := 3;
            end;
          end else if (S < LS) or (S > LE) then begin  // ���Ǳ���
            if (FCurHotDate = S) then begin
              DoDrawItemBackground(Canvas, FDrawable.FDefault, LR, FDrawable.IsCircle);
              if IsPressed then begin
                LColor := FTextSettings.FColor.FPressed;
                ColorIndex := 13;
              end else begin
                LColor := FTextSettings.FColor.FOutMonthHot;
                ColorIndex := 11;
              end;
            end else begin
              LColor := FTextSettings.FColor.FOutMonth;
              ColorIndex := 10;
            end;
          end else if (Week = 0) or (Week = 6) then begin // ��ĩ
            if (FCurHotDate = S) then begin
              DoDrawItemBackground(Canvas, FDrawable.FDefault, LR, FDrawable.IsCircle);
              if IsPressed then begin
                LColor := FTextSettings.FColor.FPressed;
                ColorIndex := 13;
              end else begin
                LColor := FTextSettings.FColor.FWeekendHot;
                ColorIndex := 9;
              end;
            end else begin
              LColor := FTextSettings.FColor.FWeekend;
              ColorIndex := 8;
            end;
          end else if (FCurHotDate = S) then begin   // ��ͣ
            DoDrawItemBackground(Canvas, FDrawable.FDefault, LR, FDrawable.IsCircle);
            if IsPressed then begin
              LColor := FTextSettings.FColor.FPressed;
              ColorIndex := 13;
            end else begin
              LColor := FTextSettings.FColor.FHovered;
              ColorIndex := 2;
            end;
          end else if TCalendarWeekItem(Week) in DaysOfWeekHighlighted then begin  // ������ʾ
            LColor := FTextSettings.FColor.FHighlight;
            ColorIndex := 12;
          end;

          if LColor = 0 then
            LColor := FTextSettings.FColor.FDefault;

          LY := Y + FRowHeihgt - L;
          FTextSettings.FillText(Canvas, RectF(X, Y, X + W, LY),
            IntToStr(D), LOpacity, LColor,
            FTextSettings.FillTextFlags, nil, 0, TTextAlign.Center);

          // ��ũ�������
          if Lunar then begin
            LItem := GetLunarData(S, AState);
            if LItem.Text <> '' then begin
              LColor := 0;
              if (ColorIndex = 0) or (ColorIndex = 1) or (ColorIndex = 12) then begin
                if LItem.IsTerm then
                  LColor := TCalendarLunarColor(FTextSettingsOfLunar.FColor).FTerm
                else if LItem.IsHoliday then
                  LColor := TCalendarLunarColor(FTextSettingsOfLunar.FColor).FHoliday
                else if LItem.IsLunarHoliday then
                  LColor := TCalendarLunarColor(FTextSettingsOfLunar.FColor).FHolidayLunar;
                if LColor = 0 then
                  LColor := FTextSettingsOfLunar.FColor.GetColor(ColorIndex);
              end else
                LColor := FTextSettingsOfLunar.FColor.GetColor(ColorIndex);
              if LColor = 0 then
                LColor := FTextSettingsOfLunar.FColor.FDefault;
              LY := LY + FRowLunarPadding;
              FTextSettingsOfLunar.FillText(Canvas, RectF(X, LY, X + W, LY + FRowLunarHeight),
                string(LItem.Text), LOpacity, LColor,
                FTextSettingsOfLunar.FillTextFlags, nil, 0, TTextAlign.Center);
            end;
          end;

        end;

      end;
      Inc(S);
      X := X + W;

      if (not IsEnd) and ((S = LS) or (S > LE)) then begin
        D := 1;
        if S > LE then
          IsEnd := True;
      end else
        Inc(D);
    end;

    Y := Y + FRowHeihgt + FRowPadding + LunarHeight;

    if L > 0 then // ������
      Canvas.FillRect(RectF(R.Left, Y - L, R.Right, Y), 0, 0, [], LOpacity, FDividerBrush);
  end;

  // ������
  if Assigned(FDividerBrush) and (coShowCosLines in FOptions) then begin
    X := LX;
    Y := R.Top;
    if (coCosLinesOut in FOptions) and (WeekRowTop <> -$FFFF) then
      Y := WeekRowTop;
    for I := 1 to 6 do begin
      X := X + W;
      Canvas.FillRect(RectF(X - 1, Y, X, R.Bottom), 0, 0, [], LOpacity, FDividerBrush);
    end;
  end;

  R.Left := LX;
end;

procedure TCalendarViewBase.DoDrawItemBackground(Canvas: TCanvas;
  ABrush: TBrush; const R: TRectF; IsCircle: Boolean);
var
  LW, LH, LR: Single;
begin
  if ABrush = nil then
    Exit;
  if IsCircle then begin
    LW := R.Width;
    LH := R.Height;
    if coEllipseSelect in FOptions then begin
      FDrawable.FillArc(Canvas, PointF(R.Left + LW * 0.5, R.Top + LH * 0.5), PointF(LW * 0.5, LH * 0.5), 0, 360, Opacity, ABrush);
    end else  begin
      LR := Min(LW, LH) * 0.5;
      FDrawable.FillArc(Canvas, PointF(R.Left + LW * 0.5, R.Top + LH * 0.5), PointF(LR, LR), 0, 360, Opacity, ABrush);
    end;
  end else
    FDrawable.DrawBrushTo(Canvas, ABrush, R);
end;

procedure TCalendarViewBase.DoDrawMonths(Canvas: TCanvas; const R: TRectF;
  const AState: TCalendarDrawState);
var
  LColor: TAlphaColor;
  W, H, LOpacity: Single;
  X, Y: Single;
  I: Integer;
  LR: TRectF;
begin
  X := R.Left;
  Y := R.Top;
  W := R.Width / 4;
  H := R.Height / 3;
  LOpacity := Opacity;

  for I := 0 to 11 do begin
    LColor := 0;
    LR := RectF(X, Y, X + W - 1, Y + H - 1);

    if I = AState.Month - 1 then begin
      DoDrawItemBackground(Canvas, FDrawable.FDefault,  LR, FDrawable.IsCircle);
      LColor := FTextSettings.FColor.FHovered;
    end else if FCurHotDate = I + 1 then begin
      DoDrawItemBackground(Canvas, FDrawable.FDefault, LR, FDrawable.IsCircle);
      if IsPressed then
        LColor := FTextSettings.FColor.FPressed
      else
        LColor := FTextSettings.FColor.FHovered;
    end;
    if LColor = 0 then
      LColor := FTextSettings.FColor.FDefault;
    if LColor and $FF000000 <> 0 then begin
      FTextSettings.FillText(Canvas, LR,
        FInnerLanguage.MonthsStrList[I], LOpacity, LColor,
        FTextSettings.FillTextFlags, nil, 0, TTextAlign.Center);
    end;
    if I mod 4 = 3 then begin
      X := R.Left;
      Y := Y + H;
    end else
      X := X + W;
  end;
end;

procedure TCalendarViewBase.DoDrawNavigation(Canvas: TCanvas; const R: TRectF; const AState: TCalendarDrawState);
var
  LR: TRectF;
  LColor, SColor: TAlphaColor;
  LOpacity: Single;
  LY: Integer;
begin
  LOpacity := Opacity;
  LColor := FTextSettingsOfTitle.Color;
  LR := RectF(R.Left, R.Top, R.Left + CDefaultNextUpW, R.Bottom - 1);

  if (DrawState = TViewState.Pressed) and (FTextSettings.FColor.FPressed <> 0) then
    SColor := FTextSettings.FColor.FPressed
  else if FTextSettings.FColor.FHovered <> 0 then
    SColor := FTextSettings.FColor.FHovered
  else
    SColor := LColor;

  if FCurHotDate = BID_Up then begin
    DoDrawItemBackground(Canvas, FDrawable.FDefault, LR, FDrawable.IsCircle);
    TTmpSimpleTextSettings(FTextSettingsOfTitle).FColor := SColor;
  end;
  FTextSettingsOfTitle.Draw(Canvas, #$00ab, LR, LOpacity, TViewState.None, TLayoutGravity.Center);

  LR := RectF(LR.Right, R.Top, R.Right - CDefaultNextUpW, R.Bottom - 1);
  if FCurHotDate = BID_Navigation then begin
    DoDrawItemBackground(Canvas, FDrawable.FDefault, LR, False);
    TTmpSimpleTextSettings(FTextSettingsOfTitle).FColor := SColor;
  end else
    TTmpSimpleTextSettings(FTextSettingsOfTitle).FColor := LColor;

  case FCurViewType of
    Days:
      FTextSettingsOfTitle.Draw(Canvas, FInnerLanguage.DateToStr(AState.Value), LR, LOpacity, TViewState.None, TLayoutGravity.Center);
    Months:
      FTextSettingsOfTitle.Draw(Canvas, IntToStr(AState.Year), LR, LOpacity, TViewState.None, TLayoutGravity.Center);
    Years:
      begin
        LY := AState.Year div 10 * 10;
        FTextSettingsOfTitle.Draw(Canvas, Format('%d-%d', [LY, LY + 9]), LR, LOpacity, TViewState.None, TLayoutGravity.Center);
      end;
    Decades:
      begin
        LY := AState.Year div 100 * 100;
        FTextSettingsOfTitle.Draw(Canvas, Format('%d-%d', [LY, LY + 90]), LR, LOpacity, TViewState.None, TLayoutGravity.Center);
      end;
    Centuries:
      begin
        LY := AState.Year div 1000 * 1000;
        FTextSettingsOfTitle.Draw(Canvas, Format('%d-%d', [LY, LY + 900]), LR, LOpacity, TViewState.None, TLayoutGravity.Center);
      end;
  end;

  LR := RectF(LR.Right, R.Top, R.Right, R.Bottom - 1);
  if FCurHotDate = BID_Next then begin
    DoDrawItemBackground(Canvas, FDrawable.FDefault, LR, FDrawable.IsCircle);
    TTmpSimpleTextSettings(FTextSettingsOfTitle).FColor := SColor;
  end else
    TTmpSimpleTextSettings(FTextSettingsOfTitle).FColor := LColor;
  FTextSettingsOfTitle.Draw(Canvas, #$00bb, LR, LOpacity, TViewState.None, TLayoutGravity.Center);

  TTmpSimpleTextSettings(FTextSettingsOfTitle).FColor := LColor;
end;

procedure TCalendarViewBase.DoDrawWeekRow(Canvas: TCanvas; const R: TRectF; const AState: TCalendarDrawState);
var
  X, W, L: Single;
  I, J: Integer;
  Items: TArray<string>;
  LColor: TAlphaColor;
begin
  W := R.Width;
  X := R.Left;
  if coCalendarWeeks in FOptions then begin
    W := W - FWeeksWidth;
    X := X + FWeeksWidth;
  end;
  W := W / 7;
  Items := FInnerLanguage.WeekStrList;
  if Assigned(FDividerBrush) and ((coShowWeekLine in FOptions) or (coShowRowLines in FOptions)) then
    L := 1
  else
    L := 0;

  if Assigned(FDrawable.FEnabled) then
    FDrawable.DrawBrushTo(Canvas, FDrawable.FEnabled, R);

  LColor := FTextSettingsOfTitle.Color;
  for I := 0 to 6 do begin
    J := (I + FWeekStart) mod 7;
    if ((J = 0) or (J = 6)) and (FTextSettings.FColor.FWeekend <> 0) then
      TTmpSimpleTextSettings(FTextSettingsOfTitle).FColor := FTextSettings.FColor.FWeekend
    else
      TTmpSimpleTextSettings(FTextSettingsOfTitle).FColor := LColor;
    FTextSettingsOfTitle.Draw(Canvas, Items[J],
      RectF(X, R.Top, X + W, R.Bottom - L), Opacity, TViewState.None, TLayoutGravity.Center);
    X := X + W;
  end;
  TTmpSimpleTextSettings(FTextSettingsOfTitle).FColor := LColor;

  if L > 0 then begin
    FDividerBrush.Color := FDivider;
    Canvas.FillRect(RectF(R.Left, R.Bottom - L, R.Right, R.Bottom), 0, 0, [], Opacity, FDividerBrush);
  end;
end;

procedure TCalendarViewBase.DoDrawYears(Canvas: TCanvas; const R: TRectF;
  const YearInterval: Integer; const AState: TCalendarDrawState);
var
  LColor: TAlphaColor;
  W, H, LOpacity: Single;
  X, Y: Single;
  I, LY: Integer;
  LR: TRectF;
begin
  X := R.Left;
  Y := R.Top;
  W := R.Width / 4;
  H := R.Height / 3;

  LY := YearInterval * 10;
  LY := AState.Year div LY * LY - YearInterval;
  LOpacity := Opacity;

  for I := 0 to 11 do begin
    LColor := 0;
    LR := RectF(X, Y, X + W - 1, Y + H - 1);

    if LY = AState.Year then begin
      DoDrawItemBackground(Canvas, FDrawable.FDefault,  LR, FDrawable.IsCircle);
      LColor := FTextSettings.FColor.FHovered;
    end else if (I = 0) or (I = 11) then begin
      if FCurHotDate = I + 1 then begin
        DoDrawItemBackground(Canvas, FDrawable.FDefault, LR, FDrawable.IsCircle);
        if IsPressed then
          LColor := FTextSettings.FColor.FPressed
        else
          LColor := FTextSettings.FColor.FOutMonthHot;
      end else
        LColor := FTextSettings.FColor.FOutMonth;
    end else if FCurHotDate = I + 1 then begin
      DoDrawItemBackground(Canvas, FDrawable.FDefault, LR, FDrawable.IsCircle);
      if IsPressed then
        LColor := FTextSettings.FColor.FPressed
      else
        LColor := FTextSettings.FColor.FHovered;
    end;

    if LColor = 0 then
      LColor := FTextSettings.FColor.FDefault;

    if LColor and $FF000000 <> 0 then begin
      FTextSettings.FillText(Canvas, LR,
        IntToStr(LY), LOpacity, LColor,
        FTextSettings.FillTextFlags, nil, 0, TTextAlign.Center);
    end;

    Inc(LY, YearInterval);

    if I mod 4 = 3 then begin
      X := R.Left;
      Y := Y + H;
    end else
      X := X + W;
  end;
end;

procedure TCalendarViewBase.DoMouseLeave;
begin
  FCurHotDate := InvaludeDate;
  inherited DoMouseLeave;
end;

procedure TCalendarViewBase.DoOptionsChange;
begin
  InitDividerBrush();
  ParseValue(FValue, FCurState);
  if IsAutoSize then
    DoAutoSize;
  Invalidate;
end;

procedure TCalendarViewBase.DoRecalcSize(var AWidth, AHeight: Single);
var
  W, H, V: Single;
begin
  if FInFitSize or (Scene = nil) or (not Assigned(FTextSettings)) or (not AutoSize) then
    Exit;
  FInFitSize := True;
  H := Padding.Top + Padding.Bottom;
  W := 210 + Padding.Left + Padding.Right;
  if coCalendarWeeks in FOptions then
    W := W + FWeeksWidth;

  if Assigned(FBackground) and Assigned(TDrawableBorder(FBackground)._Border) and
    (TDrawableBorder(FBackground)._Border.Style <> TViewBorderStyle.None) then
  begin
    H := H + TDrawableBorder(FBackground)._Border.Width * 2;
    W := W + TDrawableBorder(FBackground)._Border.Width * 2;
  end;

  if AWidth > W then
    W := AWidth;

  if coShowNavigation in FOptions then
    H := H + FRowHeihgt + FRowPadding;

  case FCurViewType of
    Days:
      begin
        if coShowWeek in FOptions then
          H := H + FRowHeihgt + FRowPadding;

        V := FRowHeihgt + FRowPadding;
        if coShowLunar in FOptions then
          V := V + FRowLunarHeight + Max(0, FRowLunarPadding);
        FCurState.RowHeight := V;
        H := H + V * FCurState.Rows;
      end;
    else
      H := H + GetNotDaysRowHeight(3) * 3;
  end;

  if (coShowTodayButton in FOptions) or (coShowClearButton in FOptions) then
    H := H + FRowHeihgt + FRowPadding;

  AWidth := W;
  AHeight := H;
  FInFitSize := False;
end;

procedure TCalendarViewBase.DoTextSettingsChange(Sender: TObject);
begin
  if TTextSettingsBase(Sender).IsSizeChange then begin
    if IsAutoSize then
      DoAutoSize;
  end;
  Repaint;
  if TTextSettingsBase(Sender).IsEffectsChange then
    UpdateEffects;
end;

function TCalendarViewBase.GetAniX: Single;
begin
  Result := FAniCalc.ViewportPositionF.X;
end;

function TCalendarViewBase.GetAutoSize: Boolean;
begin
  Result := FTextSettings.AutoSize;
end;

function TCalendarViewBase.GetDefaultSize: TSizeF;
begin
  Result := TSizeF.Create(300, 315);
  if (csDesigning in ComponentState) then
    ParseValue(FValue, FCurState);
end;

function TCalendarViewBase.GetHoverDate: TDate;
begin
  if (FCurHotDate >= InvaludeDate) or (FCurViewType <> TCalendarViewType.Days) then
    Result := 0
  else
    Result := (FCurHotDate);
end;

function TCalendarViewBase.GetLanguage: ICalendarLanguage;
begin
  Result := FLanguage;
end;

function TCalendarViewBase.GetLunarData(const LDate: Integer; const AState: TCalendarDrawState): TCalendarDateItem;
begin
  if Assigned(FOnGetLunarData) then begin
    Result.Text := '';
    Result.IsTerm := False;
    Result.IsHoliday := False;
    Result.IsLunarHoliday := False;
    FOnGetLunarData(Self, (LDate), Result)
  end else begin
    if LDate - AState.DrawS < Length(AState.LunarDataList) then
      Result := AState.LunarDataList[LDate - AState.DrawS]
    else
      Result.Text := '';
  end;
end;

function TCalendarViewBase.GetMonthBegin: TDate;
begin
  Result := FCurState.First;
end;

function TCalendarViewBase.GetMonthEnd: TDate;
begin
  Result := FCurState.Last;
end;

function TCalendarViewBase.GetNotDaysRowHeight(const RowCount: Integer): Single;
begin
  Result := FRowHeihgt + FRowPadding;
  if coShowLunar in FOptions then
    Result := Result + FRowLunarHeight + Max(0, FRowLunarPadding);
  Result := Max(Result * 2, 42);
end;

function TCalendarViewBase.GetValue: TDate;
begin
  if FSelected then
    Result := FValue
  else
    Result := 0;
end;

procedure TCalendarViewBase.InitDividerBrush;
begin
  if ((coShowWeekLine in FOptions) or (coShowRowLines in FOptions) or (coShowCosLines in FOptions)) and
    (FDivider and $FF000000 <> 0)
  then begin
    if not Assigned(FDividerBrush) then
      FDividerBrush := TBrush.Create(TBrushKind.Solid, TAlphaColorRec.Null);
  end else
    FreeAndNil(FDividerBrush);
end;

function TCalendarViewBase.IsAutoSize: Boolean;
begin
  Result := AutoSize and (HeightSize <> TViewSize.FillParent);
end;

function TCalendarViewBase.IsEndDateStored: Boolean;
begin
  Result := FEndDate <> 0;
end;

function TCalendarViewBase.IsInvalidValue(const Value: Integer): Boolean;
begin
  Result := True;
  if FDaysOfWeekDisabled <> [] then begin
    if TCalendarWeekItem(DayOfWeek((Value)) - 1) in FDaysOfWeekDisabled then
      Exit;
  end;
  if ((FStartDate <> 0) and (Value < Trunc(FStartDate))) or
    ((FEndDate <> 0) and (Value > Trunc(FEndDate)))
  then
    Exit;
  Result := False;
end;

function TCalendarViewBase.IsStartDateStored: Boolean;
begin
  Result := FStartDate <> 0;
end;

function TCalendarViewBase.IsStoredRowHeihgt: Boolean;
begin
  Result := FRowHeihgt <> CDefaultRowHeihgt;
end;

function TCalendarViewBase.IsStoredRowLunarHeight: Boolean;
begin
  Result := FRowLunarHeight <> CDefaultRowLunarHeight;
end;

function TCalendarViewBase.IsStoredRowLunarPadding: Boolean;
begin
  Result := FRowLunarPadding <> 0;
end;

function TCalendarViewBase.IsStoredRowPadding: Boolean;
begin
  Result := FRowPadding <> 0;
end;

function TCalendarViewBase.IsStoredWeeksWidth: Boolean;
begin
  Result := FWeeksWidth <> CDefaultWeeksWidth;
end;

procedure TCalendarViewBase.Loaded;
begin
  inherited Loaded;
  FTextSettings.OnChanged := DoTextSettingsChange;
  FTextSettingsOfLunar.OnChanged := DoTextSettingsChange;
  FTextSettingsOfTitle.OnChanged := DoTextSettingsChange;
  FTextSettingsOfWeeks.OnChanged := DoTextSettingsChange;
  FDrawable.OnChanged := DoDrawableChange;

  ViewType := FViewTypeStart;
  if FValue < 1 then
    ParseValue(FValue, FCurState);
  if IsAutoSize then
    DoAutoSize;
end;

procedure TCalendarViewBase.MouseDown(Button: TMouseButton; Shift: TShiftState;
  x, y: single);
begin
  inherited;
  FAning := 0;
  FDownX := X;
  FDownTime := GetTimestamp;
  FStartScroll := True;
  FCanAniMove := False;
  FAniCalc.MouseDown(x, y);
end;

procedure TCalendarViewBase.MouseMove(Shift: TShiftState; X, Y: Single);

  function PointF(const P: TPointD): TPointF;
  begin
    Result.X := P.X;
    Result.Y := P.Y;
  end;

var
  P: TPointF;
  ID, LX, LY: Integer;
begin
  if (csDesigning in ComponentState) or (ssLeft in Shift) or (ssRight in Shift) then begin
    if FStartScroll then begin
      FStartScroll := False;
      P := PointF(FAniCalc.DownPoint);
      if Abs(Y - P.Y)  > Abs(X - P.X) then
        FCanAniMove := False
      else
        FCanAniMove := True;
      FAniCalc.Shown := False;
    end;
    if FCanAniMove then
      FAniCalc.MouseMove(x, y);
    inherited;
    Exit;
  end;

  if FAning <> 0 then begin
    inherited;
    Exit;
  end;

  P.X := X;
  P.Y := Y;
  ID := InvaludeDate;

  if IsPointInRect(P, FRangeOfDays) then begin
    // ������������
    case FCurViewType of
      Days:
        begin
          X := FRangeOfDays.Width / 7;
          Y := FRangeOfDays.Height / FCurState.Rows;
          LX := Trunc((P.X - FRangeOfDays.Left) / X);
          if LX > 6 then
            Exit;
          LY := Trunc((P.Y - FRangeOfDays.Top) / Y);
          ID := FCurState.DrawS + LY * 7 + LX;
          if IsInvalidValue(ID) then
            ID := InvaludeDate;
          if (ID <> InvaludeDate) and (not (coShowBeforeAfter in FOptions)) then begin
            if (ID < FCurState.First) or (ID > FCurState.Last) then
              ID := InvaludeDate;
          end;
        end;
    else
      begin
        X := FRangeOfDays.Width / 4;
        Y := FRangeOfDays.Height / 3;
        LX := Trunc((P.X - FRangeOfDays.Left) / X);
        if LX > 3 then
          Exit;
        LY := Trunc((P.Y - FRangeOfDays.Top) / Y);
        ID := LY * 4 + LX + 1;
      end;
    end;
  end else if (P.Y > 0) and IsPointInRect(P, FRangeOfNavigation) then begin
    // �ڵ���������
    if P.X < FRangeOfNavigation.Left + CDefaultNextUpW then
      ID := BID_Up
    else if P.X > FRangeOfNavigation.Right - CDefaultNextUpW then
      ID := BID_Next
    else
      ID := BID_Navigation;
  end else begin
    LY := 0;
    if (coShowTodayButton in FOptions) then
      Inc(LY);
    if (coShowClearButton in FOptions) then
      Inc(LY, 2);
    if (LY > 0) and (P.Y > FRangeOfDays.Bottom) and (P.Y < FRangeOfDays.Bottom + FRowHeihgt) and
      (P.X > FRangeOfDays.Left) and (P.X < FRangeOfDays.Right) then
    begin
      // �ڰ�ť������
      if LY = 3 then begin
        if P.X > FRangeOfDays.Left + FRangeOfDays.Width * 0.5 then
          ID := BID_Clear
        else
          ID := BID_Today;
      end else if LY = 1 then
        ID := BID_Today
      else
        ID := BID_Clear;
    end;
  end;

  if FCurHotDate <> ID then begin
    FCurHotDate := ID;
    Invalidate;
  end;

  inherited;
end;

procedure TCalendarViewBase.MouseUp(Button: TMouseButton; Shift: TShiftState; x,
  y: single);
var
  I: Integer;
  NewH: Single;
begin
  inherited;
  FAniCalc.MouseUp(X, Y);
  UpdateScrollLimits;

  if (Abs(FDownX - X) > (Width * 0.6)) or (GetVolecity(X) > 80) then begin
    // ��Ҫ�л�����ҳ����ҳ��
    FAniCalc.OnChanged := nil;
    if FAniCalc.ViewportPosition.X > 0 then begin  // ��
      FAning := BID_Next;
      X := Width;
    end else begin
      FAning := BID_Up;
      X := -Width;
    end;

    NewH := 0;
    if (FCurViewType = TCalendarViewType.Days) and AutoSize then begin
      if (FAning = BID_Next) and (FCurState.Right <> nil) then
        I := FCurState.Right.Rows
      else if FCurState.Left <> nil then
        I := FCurState.Left.Rows
      else
        I := 0;
      if (I <> 0) and (I <> FCurState.Rows) then
        NewH := Height + (I - FCurState.Rows) * FCurState.RowHeight;
    end;

    if NewH <> 0 then begin
      // ����ı�߶�
      FInFitSize := True;
      TFrameAnimator.AnimateFloat(Self, 'Height', NewH,
        procedure (Sender: TObject)
        begin
          FInFitSize := False;
        end
      ,0.2);
    end;

    TFrameAnimator.AnimateFloat(Self, 'AniX', X,
      procedure (Sender: TObject)
      begin
        FAniCalc.OnChanged := AniCalcChange;
        AniCalcStop(Sender);
      end,
      procedure(Sender: TObject)
      begin
        AniCalcChange(Sender);
      end
    , 0.2);
  end;
end;

procedure TCalendarViewBase.PaintBackground;
var
  W: Single;
  LValue: TDate;
begin
  if AbsoluteInVisible or (csLoading in ComponentState) then
    Exit;
  if (FLanguage <> nil) then
    FInnerLanguage := FLanguage
  else
    FInnerLanguage := DefaultLanguage;

  if Assigned(FBackground) then
    FBackground.Draw(Canvas);

  if FCanAniMove then
    FCurState.XOffset := -FAniCalc.ViewportPosition.X
  else
    FCurState.XOffset := 0;
  if FCurState.XOffset <> 0 then begin
    W := Width;
    if Abs(FCurState.XOffset) > W then begin
      if FCurState.XOffset < 0 then
        FCurState.XOffset := -W
      else
        FCurState.XOffset := W;
    end;
    PaintToCanvas(Canvas, FCurState);
    if FCurState.XOffset < 0 then begin  // ����
      if FCurState.Right = nil then begin
        New(FCurState.Right);
        FillChar(FCurState.Right^, SizeOf(FCurState), 0);
      end;
      FCurState.Right.XOffset := FCurState.XOffset + W;

      LValue := IncMonth(FValue, CalcMonthOffset(1), False);
      if FCurState.Right.Value <> LValue then
        ParseValue(LValue, FCurState.Right^);
      PaintToCanvas(Canvas, FCurState.Right^);
    end else if FCurState.XOffset > 0 then begin // ����
      if FCurState.Left = nil then begin
        New(FCurState.Left);
        FillChar(FCurState.Left^, SizeOf(FCurState), 0);
      end;
      FCurState.Left.XOffset := FCurState.XOffset - W;

      LValue := IncMonth(FValue, CalcMonthOffset(0), False);
      if FCurState.Left.Value <> LValue then
        ParseValue(LValue, FCurState.Left^);
      PaintToCanvas(Canvas, FCurState.Left^);
    end;
  end else
    PaintToCanvas(Canvas, FCurState);

end;

procedure TCalendarViewBase.PaintToCanvas(Canvas: TCanvas; const AState: TCalendarDrawState);
var
  R, LR: TRectF;
  LH, LT: Single;
  V: Integer;
begin
  LH := 0;
  if Assigned(FBackground) then begin
    if Assigned(TDrawableBorder(FBackground)._Border) and (TDrawableBorder(FBackground)._Border.Style <> TViewBorderStyle.None) then
      LH := TDrawableBorder(FBackground)._Border.Width;
  end;

  R := RectF(
    Padding.Left + LH + AState.XOffset,
    Padding.Top + LH,
    Width - Padding.Right - LH + AState.XOffset,
    Height - Padding.Bottom - LH
  );

  // ������
  if coShowNavigation in FOptions then begin
    LR := RectF(R.Left, R.Top, R.Right, R.Top + FRowHeihgt);
    R.Top := LR.Bottom;
    DoDrawNavigation(Canvas, LR, AState);
    FRangeOfNavigation := LR;
  end else
    FRangeOfNavigation.Clear;

  case FCurViewType of
    Days:
      begin
        // ����
        LT := -$FFFF;
        if coShowWeek in FOptions then begin
          if coCosLinesOut in FOptions then
            LT := R.Top;
          LR := RectF(R.Left, R.Top, R.Right, R.Top + FRowHeihgt);
          R.Top := LR.Bottom;
          DoDrawWeekRow(Canvas, LR, AState);
        end;

        // ����
        LH := FRowHeihgt + FRowPadding;
        if coShowLunar in FOptions then
          LH := LH + FRowLunarHeight + Max(0, FRowLunarPadding);
        LR := RectF(R.Left, R.Top, R.Right, R.Top + AState.Rows * LH);
        R.Top := LR.Bottom;
        DoDrawDatesRow(Canvas, LR, LT, AState);
        FRangeOfDays := LR;
      end;
    Months:
      begin
        // �·�
        LH := GetNotDaysRowHeight(3);
        LR := RectF(R.Left, R.Top, R.Right, R.Top + LH * 3);
        DoDrawMonths(Canvas, LR, AState);
        FRangeOfDays := LR;
        R.Top := LR.Bottom;
      end;
    Years, Decades, Centuries:
      begin
        // ��, ʮ�꣬ ����
        LH := GetNotDaysRowHeight(3);
        LR := RectF(R.Left, R.Top, R.Right, R.Top + LH * 3);
        if FCurViewType = Years then
          V := 1
        else if FCurViewType = Decades then
          V := 10
        else
          V := 100;
        DoDrawYears(Canvas, LR, V, AState);
        FRangeOfDays := LR;
        R.Top := LR.Bottom;
      end;
  end;

  // ���찴ť
  if coShowTodayButton in FOptions then begin
    if not (coShowClearButton in FOptions) then begin
      LR := RectF(R.Left, R.Top + 1, R.Right, R.Top + FRowHeihgt - 1);
      R.Top := LR.Bottom + 1;
    end else
      LR := RectF(R.Left, R.Top + 1, R.Left + (R.Right - R.Left) * 0.5, R.Top + FRowHeihgt - 1);
    DoDrawButton(Canvas, LR, FInnerLanguage.TodayStr, BID_Today);
  end;

  // �����ť
  if coShowClearButton in FOptions then begin
    if not (coShowTodayButton in FOptions) then begin
      LR := RectF(R.Left, R.Top + 1, R.Right, R.Top + FRowHeihgt - 1);
    end else begin
      LR.Left := LR.Right;
      LR.Right := R.Right;
    end;
    R.Top := LR.Bottom + 1;
    DoDrawButton(Canvas, LR, FInnerLanguage.ClearStr, BID_Clear);
  end;

end;

procedure TCalendarViewBase.ParseValue(const Value: TDate; var AState: TCalendarDrawState);
var
  S, E, Offset: Integer;
  Y, M, D: Word;
begin
  DecodeDate(Value, Y, M, D);
  AState.Value := Value;
  AState.First := Trunc(EncodeDateTime(Y, M, 1, 0, 0, 0, 0));
  AState.Month := M;
  AState.Year := Y;

  if M = 1 then
    AState.Weeks := 1
  else
    AState.Weeks := WeekOfTheYear((AState.First));

  if M < 12 then
    Inc(M)
  else begin
    M := 1;
    Inc(Y);
  end;
  AState.Last := Trunc(EncodeDateTime(Y, M, 1, 0, 0, 0, 0)) - 1;

  AState.DayOfWeek := DayOfWeek(AState.First) - 1;
  Offset := (AState.DayOfWeek - FWeekStart) mod 7;
  if Offset < 0 then
    Inc(Offset, 7);

  S := AState.First - Offset;
  E := AState.Last;
  AState.Rows := (E - S + 1) div 7;
  if (E - S + 1) mod 7 > 0 then
    Inc(AState.Rows);

  AState.DrawS := S;  // ��¼��ǰ��ʾ�Ŀ�ʼ����
  AState.DrawSD := DayOf((S));

  if (coShowLunar in FOptions) and (FCurViewType = TCalendarViewType.Days) then
    ParseValueLunar(AState)
  else
    AState.ClearLunar;
end;

procedure TCalendarViewBase.ParseValueLunar(var AState: TCalendarDrawState);
var
  E, S, I: Integer;
  Item: TLunarData;
begin
  E := AState.Rows * 7;
  AState.ClearLunar;
  SetLength(AState.LunarDataList, AState.Rows * 7);
  S := 0;
  for I := AState.DrawS to (AState.DrawS + E - 1) do begin
    Item := SolarToLunar((I));
    if Item.Year > 0 then begin
      if (coShowTerm in FOptions) and (Item.IsTerm) then begin  // ����
        AState.LunarDataList[S].Text := Item.Term;
        AState.LunarDataList[S].IsTerm := True;
        AState.LunarDataList[S].IsHoliday := False;
        AState.LunarDataList[S].IsLunarHoliday := False;
      end else begin                                  // ũ������
        if Item.Day = 1 then
          AState.LunarDataList[S].Text := Item.CnMonth
        else
          AState.LunarDataList[S].Text := Item.CnDay;
        AState.LunarDataList[S].IsTerm := False;
        AState.LunarDataList[S].IsHoliday := False;
        AState.LunarDataList[S].IsLunarHoliday := False;
      end;
    end;
    Inc(S);
  end;
end;

procedure TCalendarViewBase.Resize;
begin
  inherited;
end;

procedure TCalendarViewBase.SetAniX(const Value: Single);
begin
  FAniCalc.ViewportPositionF := PointF(Value, 0);
end;

procedure TCalendarViewBase.SetAutoSize(const Value: Boolean);
begin
  FTextSettings.AutoSize := Value;
  if Value and (not (csLoading in ComponentState)) then
    DoAutoSize;
end;

procedure TCalendarViewBase.SetCurViewType(const Value: TCalendarViewType);
begin
  if FCurViewType <> Value then begin
    if (Value < FViewTypeMin) or (Value > FViewTypeMax) then
      Exit;
    FCurViewType := Value;
    if (coShowLunar in FOptions) and (Value = TCalendarViewType.Days) then
      ParseValueLunar(FCurState);
    if IsAutoSize then
      DoAutoSize
    else
      DoChange;
  end;
end;

procedure TCalendarViewBase.SetDaysOfWeekDisabled(const Value: TCalendarWeeks);
begin
  if FDaysOfWeekDisabled <> Value then begin
    FDaysOfWeekDisabled := Value;
    DoChange;
  end;
end;

procedure TCalendarViewBase.SetDaysOfWeekHighlighted(
  const Value: TCalendarWeeks);
begin
  if FDaysOfWeekHighlighted <> Value then begin
    FDaysOfWeekHighlighted := Value;
    DoChange;
  end;
end;

procedure TCalendarViewBase.SetDivider(const Value: TAlphaColor);
begin
  if FDivider <> Value then begin
    FDivider := Value;
    InitDividerBrush();
    Invalidate;
  end;
end;

procedure TCalendarViewBase.SetDrawable(const Value: TCalendarDrawable);
begin
  FDrawable.Assign(Value);
end;

procedure TCalendarViewBase.SetEndDate(const Value: TDate);
begin
  if FEndDate <> Value then begin
    FEndDate := Value;
    DoChange();
  end;
end;

procedure TCalendarViewBase.SetLanguage(const Value: ICalendarLanguage);
begin
  if FLanguage <> Value then begin
    FLanguage := Value;
    if (not Assigned(FLanguage)) and (not (csDesigning in ComponentState)) then
      FLanguage := DefaultLanguage;
    DoChange;
  end;
end;

procedure TCalendarViewBase.SetOptions(const Value: TCalendarOptions);
begin
  if FOptions <> Value then begin
    FOptions := Value;
    DoOptionsChange();
  end;
end;

procedure TCalendarViewBase.SetRowHeihgt(const Value: Single);
begin
  if FRowHeihgt <> Value then begin
    FRowHeihgt := Value;
    if IsAutoSize then
      DoAutoSize
    else
      DoChange;
  end;
end;

procedure TCalendarViewBase.SetRowLunarHeight(const Value: Single);
begin
  if FRowLunarHeight <> Value then begin
    FRowLunarHeight := Value;
    if IsAutoSize and (coShowLunar in FOptions) then
      DoAutoSize
    else
      DoChange;
  end;
end;

procedure TCalendarViewBase.SetRowLunarPadding(const Value: Single);
begin
  if FRowLunarPadding <> Value then begin
    FRowLunarPadding := Value;
    if AutoSize and (coShowLunar in FOptions) then
      DoAutoSize
    else
      DoChange;
  end;
end;

procedure TCalendarViewBase.SetRowPadding(const Value: Single);
begin
  if FRowPadding <> Value then begin
    FRowPadding := Value;
    if IsAutoSize then
      DoAutoSize
    else
      DoChange;
  end;
end;

procedure TCalendarViewBase.SetStartDate(const Value: TDate);
begin
  if FStartDate <> Value then begin
    FStartDate := Value;
    DoChange;
  end;
end;

procedure TCalendarViewBase.SetStartView(const Value: TCalendarViewType);
begin
  if FViewTypeStart <> Value then begin
    FViewTypeStart := Value;
    ViewType := Value;
  end;
end;

procedure TCalendarViewBase.SetTextSettings(const Value: TCalendarTextSettings);
begin
  FTextSettings.Assign(Value);
end;

procedure TCalendarViewBase.SetTextSettingsOfLunar(
  const Value: TCalendarLunarTextSettings);
begin
  FTextSettingsOfLunar.Assign(Value);
end;

procedure TCalendarViewBase.SetTextSettingsOfTitle(
  const Value: TSimpleTextSettings);
begin
  FTextSettingsOfTitle.Assign(Value);
end;

procedure TCalendarViewBase.SetTextSettingsOfWeeks(
  const Value: TSimpleTextSettings);
begin
  FTextSettingsOfWeeks.Assign(Value);
end;

procedure TCalendarViewBase.SetValue(const Value: TDate);
begin
  if (FValue <> Value) or (not FSelected) then begin
    FSelected := not IsInvalidValue(Trunc(Value));
    SwitchDate(Value);
  end;
end;

procedure TCalendarViewBase.SetViewTypeMax(const Value: TCalendarViewType);
begin
  if FViewTypeMax <> Value then begin
    FViewTypeMax := Value;
    if ViewType > Value then
      ViewType := Value;
  end;
end;

procedure TCalendarViewBase.SetViewTypeMin(const Value: TCalendarViewType);
begin
  if FViewTypeMin <> Value then begin
    FViewTypeMin := Value;
    if ViewType < Value then
      ViewType := Value;
  end;
end;

procedure TCalendarViewBase.SetWeekStart(const Value: TWeekStart);
var
  LRows: Integer;
begin
  if FWeekStart <> Value then begin
    FWeekStart := Value;
    LRows := FCurState.Rows;
    ParseValue(FValue, FCurState);
    if (FCurState.Rows <> LRows) and IsAutoSize then
      DoAutoSize;
    DoChange;
  end;
end;

procedure TCalendarViewBase.SetWeeksWidth(const Value: Single);
begin
  if FWeeksWidth <> Value then begin
    FWeeksWidth := Value;
    if (coCalendarWeeks in FOptions) and IsAutoSize then
      DoAutoSize;
    DoChange;
  end;
end;

procedure TCalendarViewBase.SwitchDate(const Value: TDate; const OffsetMonth: Integer);
var
  Y, M, D: Word;
  YY, M2, D2: Word;
  Y2: Integer;
  LAutoSize: Boolean;
  LChange: Boolean;
begin
  LChange := Value <> FValue;
  LAutoSize := IsAutoSize and (FCurViewType = TCalendarViewType.Days);

  DecodeDate(FValue, Y, M, D);

  if Value <> InvaludeDate then
    FValue := Value;

  if Value = InvaludeDate then begin
    YY := Y;
    M2 := M;
    D2 := D;
  end else
    DecodeDate(Value, YY, M2, D2);
  Y2 := YY;
  if OffsetMonth <> 0 then begin
    Y2 := Y2 + (OffsetMonth div 12);
    M2 := M2 + (OffsetMonth mod 12);
    while M2 > 12 do begin
      Inc(Y2);
      Dec(M2, 12);
    end;
    while M2 < 1 do begin
      Dec(Y2);
      Inc(M2, 12);
    end;
  end;
  if (Value = InvaludeDate) or (OffsetMonth <> 0) then begin
    if D2 > 28 then begin  // ����28ʱ���ܴ������ڳ�������������������
      D := DaysInMonth(EncodeDate(Y2, M2, 1));
      if D2 > D then
        D2 := D;
    end;
    if Y2 < 1 then Y2 := 1;
    if Y2 > 9999 then Y2 := 9999;
    FValue := EncodeDate(Y2, M2, D2);
    LChange := True;
  end;

  if (Y <> Y2) or (M <> M2) then begin
    FCurState.ClearLunar;
    ParseValue(FValue, FCurState);
    if LAutoSize then
      DoAutoSize;
  end else
    FCurState.Value := FValue;

  if LChange then
    DoDateChange;
end;

procedure TCalendarViewBase.Today;
begin
  DateTime := Now;
end;

procedure TCalendarViewBase.UpdateScrollLimits(Flag: Integer);
var
  Targets: array of TAniCalculations.TTarget;
begin
  if FAniCalc <> nil then begin
    SetLength(Targets, 2);
    if (Flag = 0) or (FAning = 0) then begin
      Targets[0].TargetType := TAniCalculations.TTargetType.Min;
      Targets[0].Point := TPointD.Create(0, 0);
      Targets[1].TargetType := TAniCalculations.TTargetType.Max;
      Targets[1].Point := TPointD.Create(0, 0);
    end else begin
      if FAning = BID_Up then begin
        Targets[0].TargetType := TAniCalculations.TTargetType.Min;
        Targets[0].Point := TPointD.Create(-Width, 0);
        Targets[1].TargetType := TAniCalculations.TTargetType.Max;
        Targets[1].Point := TPointD.Create(0, 0);
      end else begin
        Targets[0].TargetType := TAniCalculations.TTargetType.Min;
        Targets[0].Point := TPointD.Create(0, 0);
        Targets[1].TargetType := TAniCalculations.TTargetType.Max;
        Targets[1].Point := TPointD.Create(Max(0, Width), 0);
      end;
    end;
    FAniCalc.SetTargets(Targets);
  end;
end;

{ TCalendarColor }

procedure TCalendarColor.Assign(Source: TPersistent);
var
  Src: TCalendarColor;
begin
  if Source = nil then begin
    Self.FDefault := TAlphaColorRec.Null;
    Self.FHovered := TAlphaColorRec.Null;
    Self.FToday := TAlphaColorRec.Null;
    Self.FTodayHot := TAlphaColorRec.Null;
    Self.FSelected := TAlphaColorRec.Null;
    Self.FSelectedHot := TAlphaColorRec.Null;
    Self.FEnabled := TAlphaColorRec.Null;
    Self.FWeekend := TAlphaColorRec.Null;
    Self.FWeekendHot := TAlphaColorRec.Null;
    Self.FOutMonth := TAlphaColorRec.Null;
    Self.FOutMonthHot := TAlphaColorRec.Null;
    Self.FPressed := TAlphaColorRec.Null;
    Self.FHighlight := TAlphaColorRec.Null;
    if Assigned(FOnChanged) then
      FOnChanged(Self);
  end else if Source is TCalendarColor then begin
    Src := TCalendarColor(Source);
    Self.FDefault := Src.FDefault;
    Self.FHovered := Src.FHovered;
    Self.FToday := Src.FToday;
    Self.FTodayHot := Src.FTodayHot;
    Self.FSelected := Src.FSelected;
    Self.FSelectedHot := Src.FSelectedHot;
    Self.FEnabled := Src.FEnabled;
    Self.FWeekend := Src.FWeekend;
    Self.FWeekendHot := Src.FWeekendHot;
    Self.FOutMonth := Src.FOutMonth;
    Self.FOutMonthHot := Src.FOutMonthHot;
    Self.FPressed := Src.FPressed;
    Self.FHighlight := Src.FHighlight;
    if Assigned(FOnChanged) then
      FOnChanged(Self);
  end else
    inherited;
end;

function TCalendarColor.ColorDefaultStored: Boolean;
begin
  Result := GetColorStoreState(1);
end;

function TCalendarColor.ColorEnabledStored: Boolean;
begin
  Result := GetColorStoreState(7);
end;

function TCalendarColor.ColorHighlightStored: Boolean;
begin
  Result := GetColorStoreState(12);
end;

function TCalendarColor.ColorHoveredStored: Boolean;
begin
  Result := GetColorStoreState(2);
end;

function TCalendarColor.ColorOutMonthHotStored: Boolean;
begin
  Result := GetColorStoreState(11);
end;

function TCalendarColor.ColorOutMonthStored: Boolean;
begin
  Result := GetColorStoreState(10);
end;

function TCalendarColor.ColorPressedStored: Boolean;
begin
  Result := GetColorStoreState(13);
end;

function TCalendarColor.ColorSelectedHotStored: Boolean;
begin
  Result := GetColorStoreState(6);
end;

function TCalendarColor.ColorSelectedStored: Boolean;
begin
  Result := GetColorStoreState(5);
end;

function TCalendarColor.ColorTodayHotStored: Boolean;
begin
  Result := GetColorStoreState(4);
end;

function TCalendarColor.ColorTodayStored: Boolean;
begin
  Result := GetColorStoreState(3);
end;

function TCalendarColor.ColorWeekendHotStored: Boolean;
begin
  Result := GetColorStoreState(9);
end;

function TCalendarColor.ColorWeekendStored: Boolean;
begin
  Result := GetColorStoreState(8);
end;

constructor TCalendarColor.Create(const ADefaultColor: TAlphaColor);
begin
  FDefault := ADefaultColor;
  FHovered := TAlphaColorRec.Null;
  FToday := TAlphaColorRec.Red;
  FTodayHot := TAlphaColorRec.Red;
  FSelected := TAlphaColorRec.White;
  FSelectedHot := TAlphaColorRec.White;
  FEnabled := $ff999999;
  FWeekend := $ff777777;
  FWeekendHot := $ff777777;
  FOutMonth := $ffc0c1c2;
  FOutMonthHot := FOutMonth;
  FPressed := $ff000000;
  FHighlight := 0;
end;

destructor TCalendarColor.Destroy;
begin
  inherited;
end;

procedure TCalendarColor.DoChange(Sender: TObject);
begin
  if Assigned(FOnChanged) then
    FOnChanged(Sender);
end;

function TCalendarColor.GetColor(const Index: Integer): TAlphaColor;
begin
  case Index of
    1: Result := FDefault;
    2: Result := FHovered;
    3: Result := FToday;
    4: Result := FTodayHot;
    5: Result := FSelected;
    6: Result := FSelectedHot;
    7: Result := FEnabled;
    8: Result := FWeekend;
    9: Result := FWeekendHot;
    10: Result := FOutMonth;
    11: Result := FOutMonthHot;
    12: Result := FHighlight;
    13: Result := FPressed;
  else
    Result := FDefault;
  end;
end;

function TCalendarColor.GetColorStoreState(const Index: Integer): Boolean;
begin
  Result := (FColorStoreState and Index) <> 0;
end;

procedure TCalendarColor.SetColorStoreState(const Index: Integer;
  const Value: Boolean);
begin
  if Value then
    FColorStoreState := (FColorStoreState or Cardinal(Index))
  else
    FColorStoreState := (FColorStoreState and (not Index));
end;

procedure TCalendarColor.SetDefault(const Value: TAlphaColor);
begin
  if Value <> FDefault then begin
    FDefault := Value;
    DefaultChange := True;
    DoChange(Self);
  end;
end;

procedure TCalendarColor.SetEnabled(const Value: TAlphaColor);
begin
  if Value <> FEnabled then begin
    FEnabled := Value;
    EnabledChange := True;
    DoChange(Self);
  end;
end;

procedure TCalendarColor.SetHighlight(const Value: TAlphaColor);
begin
  if Value <> FHighlight then begin
    FHighlight := Value;
    HighlightChange := True;
    DoChange(Self);
  end;
end;

procedure TCalendarColor.SetHovered(const Value: TAlphaColor);
begin
  if Value <> FHovered then begin
    FHovered := Value;
    HoveredChange := True;
    DoChange(Self);
  end;
end;

procedure TCalendarColor.SetOutMonth(const Value: TAlphaColor);
begin
  FOutMonth := Value;
end;

procedure TCalendarColor.SetOutMonthHot(const Value: TAlphaColor);
begin
  FOutMonthHot := Value;
end;

procedure TCalendarColor.SetPressed(const Value: TAlphaColor);
begin
  if Value <> FPressed then begin
    FPressed := Value;
    PressedChange := True;
    DoChange(Self);
  end;
end;

procedure TCalendarColor.SetSelected(const Value: TAlphaColor);
begin
  if Value <> FSelected then begin
    FSelected := Value;
    SelectedChange := True;
    DoChange(Self);
  end;
end;

procedure TCalendarColor.SetSelectedHot(const Value: TAlphaColor);
begin
  if Value <> FSelectedHot then begin
    FSelectedHot := Value;
    SelectedHotChange := True;
    DoChange(Self);
  end;
end;

procedure TCalendarColor.SetToday(const Value: TAlphaColor);
begin
  if Value <> FToday then begin
    FToday := Value;
    TodayChange := True;
    DoChange(Self);
  end;
end;

procedure TCalendarColor.SetTodayHot(const Value: TAlphaColor);
begin
  if Value <> FTodayHot then begin
    FTodayHot := Value;
    TodayHotChange := True;
    DoChange(Self);
  end;
end;

procedure TCalendarColor.SetWeekend(const Value: TAlphaColor);
begin
  if Value <> FWeekend then begin
    FWeekend := Value;
    WeekendChange := True;
    DoChange(Self);
  end;
end;

procedure TCalendarColor.SetWeekendHot(const Value: TAlphaColor);
begin
  FWeekendHot := Value;
end;

{ TCalendarTextSettings }

constructor TCalendarTextSettings.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InitColor();
end;

destructor TCalendarTextSettings.Destroy;
begin
  FreeAndNil(FColor);
  inherited Destroy;
end;

function TCalendarTextSettings.GetStateColor(
  const State: TViewState): TAlphaColor;
begin
  if State = TViewState.Hovered then
    Result := FColor.FHovered
  else
    Result := FColor.FDefault;
end;

procedure TCalendarTextSettings.InitColor;
begin
  FColor := TCalendarColor.Create();
  FColor.OnChanged := DoColorChanged;
end;

procedure TCalendarTextSettings.SetColor(const Value: TCalendarColor);
begin
  FColor.Assign(Value);
end;

{ TCalendarDrawable }

procedure TCalendarDrawable.Assign(Source: TPersistent);
begin
  if Source is TCalendarDrawable then begin
    FIsCircle := TCalendarDrawable(Source).FIsCircle;
  end;
  inherited Assign(Source);
end;

function TCalendarDrawable.GetValue(const Index: Integer): TViewBrush;
begin
  Result := inherited GetBrush(TViewState(Index),
    not (csLoading in FView.GetComponentState)) as TViewBrush;
end;

procedure TCalendarDrawable.SetIsCircle(const Value: Boolean);
begin
  if FIsCircle <> Value then begin
    FIsCircle := Value;
    DoChange(Self);
  end;
end;

procedure TCalendarDrawable.SetValue(const Index: Integer;
  const Value: TViewBrush);
begin
  inherited SetValue(Index, Value);
end;

{ TCalendarLunarColor }

procedure TCalendarLunarColor.Assign(Source: TPersistent);
var
  Src: TCalendarLunarColor;
begin
  if Source = nil then begin
    Self.FTerm := TAlphaColorRec.Null;
    Self.FHoliday := TAlphaColorRec.Null;
    Self.FHolidayLunar := TAlphaColorRec.Null;
  end else if Source is TCalendarLunarColor then begin
    Src := TCalendarLunarColor(Source);
    Self.FTerm := Src.FTerm;
    Self.FHoliday := Src.FHoliday;
    Self.FHolidayLunar := Src.FHolidayLunar;
  end;
  inherited Assign(Source);
end;

function TCalendarLunarColor.ColorHolidayLunarStored: Boolean;
begin
  Result := GetColorStoreState(16);
end;

function TCalendarLunarColor.ColorHolidayStored: Boolean;
begin
  Result := GetColorStoreState(15);
end;

function TCalendarLunarColor.ColorTermStored: Boolean;
begin
  Result := GetColorStoreState(14);
end;

function TCalendarLunarColor.GetColor(const Index: Integer): TAlphaColor;
begin
  case Index of
    14: Result := FTerm;
    15: Result := FHoliday;
    16: Result := FHolidayLunar;
  else
    Result := inherited GetColor(Index);
  end;
end;

procedure TCalendarLunarColor.SetHoliday(const Value: TAlphaColor);
begin
  if Value <> FHoliday then begin
    FHoliday := Value;
    HolidayChange := True;
    DoChange(Self);
  end;
end;

procedure TCalendarLunarColor.SetHolidayLunar(const Value: TAlphaColor);
begin
  if Value <> FHolidayLunar then begin
    FHolidayLunar := Value;
    HolidayLunarChange := True;
    DoChange(Self);
  end;
end;

procedure TCalendarLunarColor.SetTerm(const Value: TAlphaColor);
begin
  if Value <> FTerm then begin
    FTerm := Value;
    TermChange := True;
    DoChange(Self);
  end;
end;

{ TCalendarLunarTextSettings }

procedure TCalendarLunarTextSettings.InitColor;
begin
  FColor := TCalendarLunarColor.Create();
  FColor.OnChanged := DoColorChanged;
end;

{ TCustomDateTimeView }

procedure TCustomDateTimeView.Click;
begin
  inherited Click;

  OpenPicker;
end;

procedure TCustomDateTimeView.ClosePicker;
begin
  if HasPicker and IsShow then begin
    {$IFDEF NEXTGEN}
    FDateTimePicker.Hide;
    {$ELSE}
    TDialog.CloseDialog(FDateTimePicker);
    {$ENDIF}
  end;
end;

constructor TCustomDateTimeView.Create(AOwner: TComponent);
{$IFDEF NEXTGEN}
var
  PickerService: IFMXPickerService;
{$ENDIF}
begin
  inherited;

  FDateTime := 0;
  FDateTimeFormat := FormatSettings.ShortDateFormat;

  if not (csDesigning in ComponentState) then begin

    {$IFDEF NEXTGEN}
    if TPlatformServices.Current.SupportsPlatformService(IFMXPickerService, PickerService)
    then
    begin
      FDateTimePicker := PickerService.CreateDateTimePicker;
      FDateTimePicker.Parent := Self;
      FDateTimePicker.OnHide := HandlerPickerClosed;
      FDateTimePicker.OnShow := HandlerPickerOpened;
      FDateTimePicker.OnDateChanged := HandlerPickerDateTimeChanged;
    end;
    {$ELSE}
    {$ENDIF}

  end;

  HitTest := True;
  CanFocus := True;
end;

destructor TCustomDateTimeView.Destroy;
begin
  {$IFNDEF NEXTGEN}
  ClosePicker;
  {$ELSE}
  ClosePicker;
  FreeAndNil(FDateTimePicker);
  {$ENDIF}
  inherited;
end;

{$IFNDEF NEXTGEN}
procedure TCustomDateTimeView.DoClickDateTimeView(Sender: TObject;
  const ID: Integer);
begin
  if (ID >= InvaludeDate) and (ID <> BID_Today) then
    Exit;
  if FDateTimePicker.ViewType = TCalendarViewType.Days then
    ClosePicker;
end;

procedure TCustomDateTimeView.DoDateChange(Sender: TObject);
begin
  HandlerPickerDateTimeChanged(Sender, FDateTimePicker.DateTime);
end;
{$ENDIF}

function TCustomDateTimeView.GetDateTime: TDateTime;
begin
  Result := FDateTime;
end;

procedure TCustomDateTimeView.HandlerPickerClosed(Sender: TObject);
begin
end;

procedure TCustomDateTimeView.HandlerPickerDateTimeChanged(Sender: TObject;
  const ADate: TDateTime);
begin
  DateTime := ADate;
end;

procedure TCustomDateTimeView.HandlerPickerOpened(Sender: TObject);
begin
end;

function TCustomDateTimeView.HasPicker: Boolean;
begin
  Result := FDateTimePicker <> nil;
end;

procedure TCustomDateTimeView.InitPicker;
begin
  {$IFDEF NEXTGEN}
  FDateTimePicker.Date := DateTime;
  {$ELSE}
  if FDateTimePicker = nil then begin
    FDateTimePicker := TCalendarView.Create(Self);
    FDateTimePicker.Background.ItemDefault.Color := TAlphaColorRec.White;
    FDateTimePicker.Background.ItemDefault.Kind := TViewBrushKind.Solid;
    TDrawableBorder(FDateTimePicker.Background).Border.Color.Default := TAlphaColorRec.Teal;
    TDrawableBorder(FDateTimePicker.Background).Border.Kind := TBrushKind.Solid;
    TDrawableBorder(FDateTimePicker.Background).Border.Style := TViewBorderStyle.RectBorder;
    FDateTimePicker.Width := 220;
    FDateTimePicker.Height := 200;
    FDateTimePicker.Options := [coShowNavigation, coShowWeek, coTodayHighlight, coShowTodayButton];
    FDateTimePicker.RowHeight := 22;
    FDateTimePicker.WeekStart := 1;
    FDateTimePicker.AutoSize := True;
    if Assigned(FLanguage) then
      FDateTimePicker.Language := FLanguage;
    FDateTimePicker.OnChange := DoDateChange;
    FDateTimePicker.OnClickView := DoClickDateTimeView;
  end;
  FDateTimePicker.DateTime := DateTime;
  {$ENDIF}
end;

function TCustomDateTimeView.IsPickerOpened: Boolean;
begin
  Result := HasPicker and IsShow;
end;

function TCustomDateTimeView.IsShow: Boolean;
begin
  Result := {$IFDEF NEXTGEN}FDateTimePicker.IsShown{$ELSE}FIsShow{$ENDIF};
end;

procedure TCustomDateTimeView.OpenPicker;
{$IFNDEF NEXTGEN}
var
  Dlg: TDialog;
{$ENDIF}
begin
  if not IsShow then
    InitPicker;
  if HasPicker and not IsShow then
  begin
    {$IFDEF NEXTGEN}
    FDateTimePicker.PreferedDisplayIndex :=
      Screen.DisplayFromPoint(Screen.MousePos).Index;
    FDateTimePicker.Show;
    {$ELSE}
    Dlg := TDialog.ShowView(Self, Self, FDateTimePicker, False, 0, 0,
      TDialogViewPosition.LeftBottom, True, TFrameAniType.None, False);
    Dlg.OnDismissListenerA :=
      procedure (Dialog: IDialog)
      begin
        FIsShow := False;
      end;
    FDateTimePicker.DoAutoSize;
    FIsShow := True;
    HandlerPickerOpened(Self);
    {$ENDIF}
  end;
end;

procedure TCustomDateTimeView.SetDateTime(const Value: TDateTime);
begin
  FDateTime := Value;
  Text := FormatDateTime(DateTimeFormat, Value);
end;

{TDateView}

constructor TDateView.Create(AOwner: TComponent);
begin
  inherited;

  FDateTimeFormat := FormatSettings.ShortDateFormat;
  {$IFDEF NEXTGEN}
  if HasPicker then
    FDateTimePicker.ShowMode := TDatePickerShowMode.Date;
  {$ENDIF}
  DateTime := Now;
end;

function TDateView.GetLanguage: ICalendarLanguage;
begin
  {$IFNDEF NEXTGEN}
  Result := FLanguage;
  {$ENDIF}
end;

procedure TDateView.SetLanguage(const Value: ICalendarLanguage);
begin
  {$IFNDEF NEXTGEN}
  FLanguage := Value;
  {$ENDIF}
end;

{TTimeView}

constructor TTimeView.Create(AOwner: TComponent);
begin
  inherited;

  FDateTimeFormat := FormatSettings.ShortTimeFormat;
  {$IFDEF NEXTGEN}
  if HasPicker then
    FDateTimePicker.ShowMode := TDatePickerShowMode.Time;
  {$ENDIF}
  DateTime := Now;
end;

{$IFNDEF NEXTGEN}
procedure TTimeView.DoTimeChange(Sender: TObject);
begin
  if Assigned(Self) then
    HandlerPickerDateTimeChanged(Self, TTimeEdit(Sender).DateTime);
end;

procedure TTimeView.ClosePicker;
begin
end;

procedure TTimeView.OpenPicker;
var
  FTimeEdit: TTimeEdit;
begin
  FTimeEdit := TTimeEdit.Create(Self);
  FTimeEdit.Width := Max(Self.Width, 100);
  FTimeEdit.Height := 24;
  FTimeEdit.Time := DateTime;
  if FDateTimeFormat = FormatSettings.ShortTimeFormat then
    FTimeEdit.TimeFormatKind := TDTFormatKind.Short
  else
    FTimeEdit.TimeFormatKind := TDTFormatKind.Long;
  FTimeEdit.OnChange := DoTimeChange;

  TDialog.ShowView(Self, Self, FTimeEdit, True, 0, 0, TDialogViewPosition.Bottom,
    True, TFrameAniType.None, False);
end;
{$ENDIF}

{ TCalendarDrawState }

procedure TCalendarDrawState.Clear;
begin
  ClearLunar();
  if Left <> nil then begin
    Left.Clear;
    Dispose(Left);
  end;
  if Right <> nil then begin
    Right.Clear;
    Dispose(Right);
  end;
end;

procedure TCalendarDrawState.ClearLunar;
var
  I: Integer;
begin
  for I := Low(LunarDataList) to High(LunarDataList) do
    LunarDataList[I].Text := '';
  SetLength(LunarDataList, 0);
end;

initialization
  DefaultLanguage := TCalendarLanguage_EN.Create(nil);

finalization
  FreeAndNil(DefaultLanguage);

end.
