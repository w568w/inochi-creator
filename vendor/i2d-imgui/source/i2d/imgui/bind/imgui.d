module i2d.imgui.bind.imgui;
enum IMGUI_VERSION = "1.92.9b";

import std.algorithm;

import std.traits;

import core.stdc.stdio;

import core.stdc.stdarg;

import core.stdc.string;

extern (C) {
    
    tType GetBitmask(tType)(ubyte accumulatedBits, ubyte numberOfBits)
    {
        OriginalType!tType blank = 0;
        for (ubyte i = accumulatedBits; i < (accumulatedBits + numberOfBits); ++i)
        {
            blank = cast(OriginalType!tType)(blank ^ (1 << i));
        }
        return cast(tType)blank;
    }
    
    tType GetValue(tType)(tType aBitField, ubyte accumulatedBits, ubyte numberOfBits) {
        tType bitmask = GetBitmask!tType(accumulatedBits, numberOfBits);
        return (aBitField & bitmask) >> accumulatedBits;
    }
    
    tType SetValue(tType)(tType aBitField, ubyte accumulatedBits, ubyte numberOfBits, tType aValue) {
        return cast(tType)((aBitField & ~GetBitmask!tType(accumulatedBits, numberOfBits)) | (aValue << accumulatedBits));
    }
    
    alias stbrp_coord = int;
    struct stbrp_node
    {
       stbrp_coord  x,y;
       stbrp_node  *next;
    };
    alias ImFontAtlasRectId = int;
    struct ImGuiDockRequest;
    alias ImS16 = short;
    alias ImU32 = uint;
    alias ImGuiSizeCallback = void  function(ImGuiSizeCallbackData* data);
    alias ImGuiContextHookCallback = void  function(ImGuiContext* ctx, ImGuiContextHook* hook);
    alias ImS8 = byte;
    alias ImU64 = ulong;
    alias ImWchar = ImWchar32;
    alias ImGuiID = uint;
    alias ImGuiTableDrawChannelIdx = ImU16;
    alias ImGuiInputTextCallback = int  function(ImGuiInputTextCallbackData* data);
    alias ImGuiDemoMarkerCallback = void  function(const(char)* file, int line, const(char)* section);
    alias ImDrawIdx = ushort;
    alias ImPoolIdx = int;
    alias ImDrawCallback = void  function(const ImDrawList* parent_list, const ImDrawCmd* cmd);
    struct ImGuiDockNodeSettings;
    alias ImS32 = int;
    alias ImGuiKeyChord = int;
    alias ImGuiMemFreeFunc = void  function(void* ptr, void* user_data);
    alias ImGuiSelectionUserData = ImS64;
    struct ImGuiTableColumnsSettings;
    alias ImU16 = ushort;
    alias ImWchar16 = ushort;
    alias ImWchar32 = uint;
    alias ImS64 = long;
    alias ImFileHandle = FILE*;
    alias ImU8 = char;
    alias ImGuiKeyRoutingIndex = ImS16;
    alias ImGuiTableColumnIdx = ImS16;
    alias ImTextureID = ImU64;
    struct ImGuiInputTextDeactivateData;
    struct ImStbTexteditState;
    alias ImGuiErrorCallback = void  function(ImGuiContext* ctx, void* user_data, const(char)* msg);
    alias ImBitArrayForNamedKeys = ImBitArray!(ImGuiKey.NamedKey_COUNT,-ImGuiKey.NamedKey_BEGIN);
    alias ImBitArrayPtr = ImU32*;
    alias ImGuiMemAllocFunc = void*  function(size_t sz, void* user_data);
    alias stbrp_node_im = stbrp_node;
    
    size_t imMemAlign(size_t size, size_t alignment)
    {
        return (size + alignment - 1) & ~(alignment - 1);
    }
    
    struct ImStableVector(tType, size_t BLOCK_SIZE) {
        int Size;
        int Capacity;
        ImVector!(tType*) Blocks;
    
        ~this()
        {
            for (int n = 0; n < Capacity; n++)
            {
                igMemFree(Blocks[n]);
            }
        }
    
        void clear()
        {
            Size = 0;
            Capacity = 0;
            Blocks.clear_delete();
        }
    
        void resize(int new_size)
        { 
            if (new_size > Capacity) 
            {
                reserve(cast(int)new_size); 
                Size = new_size; 
            }
        }
    
        void reserve(int new_cap)
        {
            new_cap = cast(int)imMemAlign(new_cap, cast(size_t)BLOCK_SIZE);
            int old_count = cast(int)(Capacity / BLOCK_SIZE);
            int new_count = cast(int)(new_cap / BLOCK_SIZE);
            if (new_count <= old_count)
            {
                return;
            }
    
            Blocks.resize(new_count);
            for (int n = old_count; n < new_count; n++)
            {
                Blocks[n] = cast(tType*)igMemAlloc(tType.sizeof * BLOCK_SIZE);
            }
            Capacity = new_cap;
        }
        
        ref auto opIndex(size_t index)
        {
            return Blocks[index / BLOCK_SIZE][index % BLOCK_SIZE];
        }
    
        ref auto push_back(const(tType) v) 
        {
            int i = Size;
            assert(i >= 0);
            if (Size == Capacity)
            {
                reserve(cast(int)(Capacity + BLOCK_SIZE));
            }  
            
            void* ptr = &Blocks[i / BLOCK_SIZE][i % BLOCK_SIZE]; 
            memcpy(ptr, &v, v.sizeof); 
            Size++; 
            return cast(tType*)ptr;        
        }
    }
    
    struct ImVector(tType) {
        int Size;
        int Capacity;
        tType* Data;
    
        // Opaque element types expose storage only; their operations belong to C++.
        static if (__traits(compiles, tType.sizeof)) {
        import core.stdc.string;
    
        // Important: never called automatically! always explicit.
        void clear_delete()() if (isPointer!(tType))
        { 
            for (int n = 0; n < Size; n++) {
                destroy(Data[n]); 
                igMemFree(cast(void*)Data[n]);
            }
                
            clear();
        }
    
        // Important: never called automatically! always explicit.
        void clear_destruct()
        { 
            for (int n = 0; n < Size; n++) 
            {
                destroy(Data[n]);
            }
    
            clear(); 
        }
    
        bool empty() const                       
        {
            return Size == 0; 
        }
    
        int size() const                        
        {
            return Size; 
        }
    
        int size_in_bytes() const               
        {
            return Size * cast(int)tType.sizeof; 
        }
    
        int max_size() const                    
        {
            return 0x7FFFFFFF / cast(int)tType.sizeof; 
        }
    
        int capacity() const                    
        {
            return Capacity; 
        }
    
        void clear()                             
        {
            if (Data) 
            {
                Size = Capacity = 0;
                igMemFree(Data);
                Data = null; 
            } 
        }
    
        void swap(ImVector* rhs)
        {
            int rhs_size = rhs.Size;
            rhs.Size = Size;
            Size = rhs_size;
            int rhs_cap = rhs.Capacity;
            rhs.Capacity = Capacity;
            Capacity = rhs_cap;
            tType* rhs_data = rhs.Data;
            rhs.Data = Data;
            Data = rhs_data;
        }
    
        int _grow_capacity(int sz) const        
        {
            int new_capacity = Capacity ? (Capacity + Capacity / 2) : 8;
            return new_capacity > sz ? new_capacity : sz; 
        }
    
        void resize(int new_size)                
        {
            if (new_size > Capacity) 
                reserve(_grow_capacity(new_size)); Size = new_size; 
        }
    
        void resize(int new_size, const tType* v)    
        {
            if (new_size > Capacity)
                reserve(_grow_capacity(new_size));
            if (new_size > Size)
                for (int n = Size; n < new_size; n++) 
                    memcpy(&Data[n], v, tType.sizeof); 
            
            Size = new_size; 
        }
    
        // Resize a vector to a smaller size, guaranteed not to cause a reallocation
        void shrink(int new_size)                
        {
            assert(new_size <= Size);
            Size = new_size; 
        } 
    
        void reserve(int new_capacity)           
        {
            if (new_capacity <= Capacity) 
                return; 
    
            tType* new_data = cast(tType*)igMemAlloc(cast(size_t)new_capacity * tType.sizeof); 
            
            if (Data) 
            {
                memcpy(new_data, Data, cast(size_t)Size * tType.sizeof); 
                igMemFree(Data);
            } 
    
            Data = new_data; 
            Capacity = new_capacity; 
        }
    
        ref auto opIndex(size_t index)
        {
            return Data[index];
        }
    
        // NB: It is illegal to call push_back/push_front/insert with a reference pointing inside the 
        // ImVector data itself! e.g. v.push_back(v[10]) is forbidden.
        void push_back(const tType* v)               
        {
            if (Size == Capacity)
                reserve(_grow_capacity(Size + 1)); 
            
            memcpy(&Data[Size], v, tType.sizeof);
            Size++; 
        }
    
        void pop_back()                          
        {
             assert(Size > 0);
             Size--; 
        }
    
        void push_front(const tType* v)              
        {
            if (Size == 0)
                push_back(v); 
            else 
                insert(Data, v); 
        }
    
        tType* erase(const tType* it)
        {
             assert(it >= Data && it < Data + Size);
             const ptrdiff_t off = it - Data;
             memmove(Data + off, Data + off + 1, (cast(size_t)Size - cast(size_t)off - 1) * tType.sizeof);
             Size--;
             return Data + off; 
        }
    
        tType* erase(const tType* it, const tType* it_last)
        {
             assert(it >= Data && it < Data + Size && it_last > it && it_last <= Data + Size);
             const ptrdiff_t count = it_last - it;
             const ptrdiff_t off = it - Data;
             memmove(Data + off, Data + off + count, (cast(size_t)Size - cast(size_t)off - count) * tType.sizeof);
             Size -= cast(int)count;
             return Data + off; 
        }
    
        tType* erase_unsorted(const tType* it)
        {
            assert(it >= Data && it < Data + Size);
            const ptrdiff_t off = it - Data;
             
            if (it < Data + Size - 1)
                memcpy(Data + off, Data + Size - 1, tType.sizeof);
            
            Size--;
            return Data + off; 
        }
    
        tType* insert(const tType* it, const tType* v)
        {
             assert(it >= Data && it <= Data + Size); 
             const ptrdiff_t off = it - Data;
             
            if (Size == Capacity) 
                reserve(_grow_capacity(Size + 1));
            
            if (off < cast(int)Size) 
                memmove(Data + off + 1, Data + off, (cast(size_t)Size - cast(size_t)off) * tType.sizeof);
    
            memcpy(&Data[off], v, tType.sizeof);
            Size++;
            return Data + off; 
        }
        }
    }
    
    struct ImSpan(tType) {
        tType* Data;
        tType* DataEnd;
    
        // Constructors, destructor
        //this() 
        //{
        //    Data = DataEnd = NULL; 
        //}
    
        this(tType* data, int size)
        {
            Data = data;
            DataEnd = data + size; 
        }
    
        this(tType* data, tType* data_end)
        {
            Data = data;
            DataEnd = data_end; 
        }
    
        void set(tType* data, int size)
        {
                Data = data;
                DataEnd = data + size; 
        }
    
        void set(tType* data, tType* data_end)
        {
            Data = data;
            DataEnd = data_end; 
        }
    
        int size() const 
        {
            return cast(int)cast(ptrdiff_t)(DataEnd - Data); 
        }
    
        int size_in_bytes() const 
        {
            return cast(int)cast(ptrdiff_t)(DataEnd - Data) * cast(int)tType.sizeof;
        }
    
        tType* opIndex(size_t i)
        {
            tType* p = Data + i;
            assert(p >= Data && p < DataEnd);
            return p; 
        }
    
        tType* begin() 
        {
            return Data; 
        }
    
        tType* end() 
        {
            return DataEnd; 
        }
    
        // Utilities
        int  index_from_ptr(const tType* it)
        { 
            assert(it >= Data && it < DataEnd); 
            const ptrdiff_t off = it - Data;
            return cast(int)off; 
        }
    }
    
    struct ImBitArray(int BITCOUNT, int OFFSET = 0)
    {
        ImU32[(BITCOUNT + 31) >> 5] Storage;
        //ImBitArray()
        //{ 
        //    ClearAllBits(); 
        //}
    
        void ClearAllBits()
        { 
            core.stdc.string.memset(Storage.ptr, 0, Storage.sizeof);
        }
    
        void SetAllBits()
        { 
            core.stdc.string.memset(Storage.ptr, 255, Storage.sizeof);
        }
    
        bool TestBit(int n) const
        { 
            n += OFFSET; 
            assert(n >= 0 && n < BITCOUNT); 
            return igImBitArrayTestBit(Storage.ptr, n); 
        }
    
        void SetBit(int n)
        { 
            n += OFFSET;
            assert(n >= 0 && n < BITCOUNT); 
            igImBitArraySetBit(Storage.ptr, n); 
        }
    
        void ClearBit(int n)
        { 
            n += OFFSET;
            assert(n >= 0 && n < BITCOUNT); 
            igImBitArrayClearBit(Storage.ptr, n); 
        }
        
        // Works on range [n..n2)
        void SetBitRange(int n, int n2)
        { 
            n += OFFSET; 
            n2 += OFFSET; 
            assert(n >= 0 && n < BITCOUNT && n2 > n && n2 <= BITCOUNT); 
            igImBitArraySetBitRange(Storage.ptr, n, n2); 
        }
    
        bool opIndex(int n) const
        { 
            n += OFFSET; 
            assert(n >= 0 && n < BITCOUNT); 
            return igImBitArrayTestBit(Storage.ptr, n); 
        }
    }
    
    struct ImPool_ImGuiTabBar {
        ImVector!(ImGuiTabBar) Buf;
        ImGuiStorage Map;
        ImPoolIdx FreeIdx;
        ImPoolIdx AliveCount;
    }
    
    struct ImPool_ImGuiMultiSelectState {
        ImVector!(ImGuiMultiSelectState) Buf;
        ImGuiStorage Map;
        ImPoolIdx FreeIdx;
        ImPoolIdx AliveCount;
    }
    
    struct ImChunkStream_ImGuiWindowSettings {
        ImVector!(char) Buf;
    }
    
    struct ImChunkStream_ImGuiTableSettings {
        ImVector!(char) Buf;
    }
    
    struct ImPool_ImGuiTable {
        ImVector!(ImGuiTable) Buf;
        ImGuiStorage Map;
        ImPoolIdx FreeIdx;
        ImPoolIdx AliveCount;
    }

    enum ImGuiOldColumnFlags {
        None = 0,
        NoBorder = 1,
        NoResize = 2,
        NoPreserveWidths = 4,
        NoForceWithinWindow = 8,
        GrowParentContentsSize = 16,
    }

    enum ImGuiLayoutType {
        Horizontal = 0,
        Vertical = 1,
    }

    enum ImGuiFreeTypeLoaderFlags {
        NoHinting = 1,
        NoAutoHint = 2,
        ForceAutoHint = 4,
        LightHinting = 8,
        MonoHinting = 16,
        Bold = 32,
        Oblique = 64,
        Monochrome = 128,
        LoadColor = 256,
        Bitmap = 512,
    }

    enum ImGuiTableBgTarget {
        None = 0,
        RowBg0 = 1,
        RowBg1 = 2,
        CellBg = 3,
    }

    enum ImGuiSeparatorFlags {
        None = 0,
        Horizontal = 1,
        Vertical = 2,
        SpanAllColumns = 4,
    }

    enum ImGuiWindowDockStyleCol {
        Text = 0,
        TabHovered = 1,
        TabFocused = 2,
        TabSelected = 3,
        TabSelectedOverline = 4,
        TabDimmed = 5,
        TabDimmedSelected = 6,
        TabDimmedSelectedOverline = 7,
        UnsavedMarker = 8,
        COUNT = 9,
    }

    enum ImDrawTextFlags {
        None = 0,
        CpuFineClip = 1,
        WrapKeepBlanks = 2,
        StopOnNewLine = 4,
    }

    enum ImGuiNextItemDataFlags {
        None = 0,
        HasWidth = 1,
        HasOpen = 2,
        HasShortcut = 4,
        HasRefVal = 8,
        HasStorageID = 16,
        HasColorMarker = 32,
    }

    enum ImGuiFocusRequestFlags {
        None = 0,
        RestoreFocusedChild = 1,
        UnlessBelowModal = 2,
    }

    enum ImGuiItemStatusFlags {
        None = 0,
        HoveredRect = 1,
        HasDisplayRect = 2,
        Edited = 4,
        ToggledSelection = 8,
        ToggledOpen = 16,
        HasDeactivated = 32,
        Deactivated = 64,
        HoveredWindow = 128,
        Visible = 256,
        HasClipRect = 512,
        HasShortcut = 1024,
        EditedInternal = 2048,
    }

    enum ImGuiHoveredFlagsI : ImGuiHoveredFlags {
        DelayMask_ = cast(ImGuiHoveredFlags)245760,
        AllowedMaskForIsWindowHovered = cast(ImGuiHoveredFlags)12479,
        AllowedMaskForIsItemHovered = cast(ImGuiHoveredFlags)262048,
    }

    enum ImGuiSliderFlagsI : ImGuiSliderFlags {
        Vertical = cast(ImGuiSliderFlags)1048576,
        ReadOnly = cast(ImGuiSliderFlags)2097152,
    }

    enum ImGuiMouseButton {
        Left = 0,
        Right = 1,
        Middle = 2,
        COUNT = 5,
    }

    enum ImGuiMouseSource {
        Mouse = 0,
        TouchScreen = 1,
        Pen = 2,
        COUNT = 3,
    }

    enum ImGuiTypingSelectFlags {
        None = 0,
        AllowBackspace = 1,
        AllowSingleCharMode = 2,
    }

    enum ImGuiDockNodeFlagsI : ImGuiDockNodeFlags {
        DockSpace = cast(ImGuiDockNodeFlags)1024,
        CentralNode = cast(ImGuiDockNodeFlags)2048,
        NoTabBar = cast(ImGuiDockNodeFlags)4096,
        HiddenTabBar = cast(ImGuiDockNodeFlags)8192,
        NoWindowMenuButton = cast(ImGuiDockNodeFlags)16384,
        NoCloseButton = cast(ImGuiDockNodeFlags)32768,
        NoResizeX = cast(ImGuiDockNodeFlags)65536,
        NoResizeY = cast(ImGuiDockNodeFlags)131072,
        DockedWindowsInFocusRoute = cast(ImGuiDockNodeFlags)262144,
        NoDockingSplitOther = cast(ImGuiDockNodeFlags)524288,
        NoDockingOverMe = cast(ImGuiDockNodeFlags)1048576,
        NoDockingOverOther = cast(ImGuiDockNodeFlags)2097152,
        NoDockingOverEmpty = cast(ImGuiDockNodeFlags)4194304,
        NoDocking = cast(ImGuiDockNodeFlags)7864336,
        SharedFlagsInheritMask_ = cast(ImGuiDockNodeFlags)-1,
        NoResizeFlagsMask_ = cast(ImGuiDockNodeFlags)196640,
        LocalFlagsTransferMask_ = cast(ImGuiDockNodeFlags)260208,
        SavedFlagsMask_ = cast(ImGuiDockNodeFlags)261152,
    }

    enum ImGuiDataAuthority {
        Auto = 0,
        DockNode = 1,
        Window = 2,
    }

    enum ImGuiInputEventType {
        None = 0,
        MousePos = 1,
        MouseWheel = 2,
        MouseButton = 3,
        MouseViewport = 4,
        Key = 5,
        Text = 6,
        Focus = 7,
        COUNT = 8,
    }

    enum ImGuiInputFlagsI : ImGuiInputFlags {
        RepeatRateDefault = cast(ImGuiInputFlags)2,
        RepeatRateNavMove = cast(ImGuiInputFlags)4,
        RepeatRateNavTweak = cast(ImGuiInputFlags)8,
        RepeatUntilRelease = cast(ImGuiInputFlags)16,
        RepeatUntilKeyModsChange = cast(ImGuiInputFlags)32,
        RepeatUntilKeyModsChangeFromNone = cast(ImGuiInputFlags)64,
        RepeatUntilOtherKeyPress = cast(ImGuiInputFlags)128,
        LockThisFrame = cast(ImGuiInputFlags)1048576,
        LockUntilRelease = cast(ImGuiInputFlags)2097152,
        CondHovered = cast(ImGuiInputFlags)4194304,
        CondActive = cast(ImGuiInputFlags)8388608,
        CondDefault_ = cast(ImGuiInputFlags)12582912,
        RepeatRateMask_ = cast(ImGuiInputFlags)14,
        RepeatUntilMask_ = cast(ImGuiInputFlags)240,
        RepeatMask_ = cast(ImGuiInputFlags)255,
        CondMask_ = cast(ImGuiInputFlags)12582912,
        RouteTypeMask_ = cast(ImGuiInputFlags)15360,
        RouteOptionsMask_ = cast(ImGuiInputFlags)245760,
        SupportedByIsKeyPressed = cast(ImGuiInputFlags)255,
        SupportedByIsMouseClicked = cast(ImGuiInputFlags)1,
        SupportedByShortcut = cast(ImGuiInputFlags)261375,
        SupportedBySetNextItemShortcut = cast(ImGuiInputFlags)523519,
        SupportedBySetKeyOwner = cast(ImGuiInputFlags)3145728,
        SupportedBySetItemKeyOwner = cast(ImGuiInputFlags)15728640,
    }

    enum ImGuiPlotType {
        Lines = 0,
        Histogram = 1,
    }

    enum ImGuiTabBarFlagsI : ImGuiTabBarFlags {
        DockNode = cast(ImGuiTabBarFlags)1048576,
        IsFocused = cast(ImGuiTabBarFlags)2097152,
        SaveSettings = cast(ImGuiTabBarFlags)4194304,
    }

    enum ImGuiTableColumnFlags {
        None = 0,
        Disabled = 1,
        DefaultHide = 2,
        DefaultSort = 4,
        WidthStretch = 8,
        WidthFixed = 16,
        NoResize = 32,
        NoReorder = 64,
        NoHide = 128,
        NoClip = 256,
        NoSort = 512,
        NoSortAscending = 1024,
        NoSortDescending = 2048,
        NoHeaderLabel = 4096,
        NoHeaderWidth = 8192,
        PreferSortAscending = 16384,
        PreferSortDescending = 32768,
        IndentEnable = 65536,
        IndentDisable = 131072,
        AngledHeader = 262144,
        IsEnabled = 16777216,
        IsVisible = 33554432,
        IsSorted = 67108864,
        IsHovered = 134217728,
        WidthMask_ = 24,
        IndentMask_ = 196608,
        StatusMask_ = 251658240,
        NoDirectResize_ = 1073741824,
    }

    enum ImGuiTooltipFlags {
        None = 0,
        OverridePrevious = 2,
    }

    enum ImGuiTabItemFlags {
        None = 0,
        UnsavedDocument = 1,
        SetSelected = 2,
        NoCloseWithMiddleMouseButton = 4,
        NoPushId = 8,
        NoTooltip = 16,
        NoReorder = 32,
        Leading = 64,
        Trailing = 128,
        NoAssumedClosure = 256,
    }

    enum ImGuiLocKey {
        VersionStr = 0,
        TableSizeOne = 1,
        TableSizeAllFit = 2,
        TableSizeAllDefault = 3,
        TableReset = 4,
        TableResetOrder = 5,
        TableResetVisibility = 6,
        WindowingMainMenuBar = 7,
        WindowingPopup = 8,
        WindowingUntitled = 9,
        OpenLink_s = 10,
        CopyLink = 11,
        DockingHideTabBar = 12,
        DockingHoldShiftToDock = 13,
        DockingDragToUndockOrMoveNode = 14,
        COUNT = 15,
    }

    enum ImGuiPopupPositionPolicy {
        Default = 0,
        ComboBox = 1,
        Tooltip = 2,
    }

    enum ImGuiConfigFlags {
        None = 0,
        NavEnableKeyboard = 1,
        NavEnableGamepad = 2,
        NoMouse = 16,
        NoMouseCursorChange = 32,
        NoKeyboard = 64,
        DockingEnable = 128,
        ViewportsEnable = 1024,
        IsSRGB = 1048576,
        IsTouchScreen = 2097152,
    }

    enum ImGuiChildFlags {
        None = 0,
        Borders = 1,
        AlwaysUseWindowPadding = 2,
        ResizeX = 4,
        ResizeY = 8,
        AutoResizeX = 16,
        AutoResizeY = 32,
        AlwaysAutoResize = 64,
        FrameStyle = 128,
        NavFlattened = 256,
    }

    enum ImGuiTableRowFlags {
        None = 0,
        Headers = 1,
    }

    enum ImGuiDataTypeI : ImGuiDataType {
        Pointer = cast(ImGuiDataType)12,
        ID = cast(ImGuiDataType)13,
    }

    enum ImGuiTreeNodeFlags {
        None = 0,
        Selected = 1,
        Framed = 2,
        AllowOverlap = 4,
        NoTreePushOnOpen = 8,
        NoAutoOpenOnLog = 16,
        DefaultOpen = 32,
        OpenOnDoubleClick = 64,
        OpenOnArrow = 128,
        Leaf = 256,
        Bullet = 512,
        FramePadding = 1024,
        SpanAvailWidth = 2048,
        SpanFullWidth = 4096,
        SpanLabelWidth = 8192,
        SpanAllColumns = 16384,
        LabelSpanAllColumns = 32768,
        NavLeftJumpsToParent = 131072,
        CollapsingHeader = 26,
        DrawLinesNone = 262144,
        DrawLinesFull = 524288,
        DrawLinesToNodes = 1048576,
    }

    enum ImGuiWindowFlags {
        None = 0,
        NoTitleBar = 1,
        NoResize = 2,
        NoMove = 4,
        NoScrollbar = 8,
        NoScrollWithMouse = 16,
        NoCollapse = 32,
        AlwaysAutoResize = 64,
        NoBackground = 128,
        NoSavedSettings = 256,
        NoMouseInputs = 512,
        MenuBar = 1024,
        HorizontalScrollbar = 2048,
        NoFocusOnAppearing = 4096,
        NoBringToFrontOnFocus = 8192,
        AlwaysVerticalScrollbar = 16384,
        AlwaysHorizontalScrollbar = 32768,
        NoNavInputs = 65536,
        NoNavFocus = 131072,
        UnsavedDocument = 262144,
        NoDocking = 524288,
        NoNav = 196608,
        NoDecoration = 43,
        NoInputs = 197120,
        DockNodeHost = 8388608,
        ChildWindow = 16777216,
        Tooltip = 33554432,
        Popup = 67108864,
        Modal = 134217728,
        ChildMenu = 268435456,
    }

    enum ImGuiNavMoveFlags {
        None = 0,
        LoopX = 1,
        LoopY = 2,
        WrapX = 4,
        WrapY = 8,
        WrapMask_ = 15,
        AllowCurrentNavId = 16,
        AlsoScoreVisibleSet = 32,
        ScrollToEdgeY = 64,
        Forwarded = 128,
        DebugNoResult = 256,
        FocusApi = 512,
        IsTabbing = 1024,
        IsPageMove = 2048,
        Activate = 4096,
        NoSelect = 8192,
        NoSetNavCursorVisible = 16384,
        NoClearActiveId = 32768,
    }

    enum ImGuiTextFlags {
        None = 0,
        NoWidthForLargeClippedText = 1,
    }

    enum ImGuiColorEditFlags {
        None = 0,
        NoAlpha = 2,
        NoPicker = 4,
        NoOptions = 8,
        NoSmallPreview = 16,
        NoInputs = 32,
        NoTooltip = 64,
        NoLabel = 128,
        NoSidePreview = 256,
        NoDragDrop = 512,
        NoBorder = 1024,
        NoColorMarkers = 2048,
        AlphaOpaque = 4096,
        AlphaNoBg = 8192,
        AlphaPreviewHalf = 16384,
        AlphaBar = 262144,
        HDR = 524288,
        DisplayRGB = 1048576,
        DisplayHSV = 2097152,
        DisplayHex = 4194304,
        Uint8 = 8388608,
        Float = 16777216,
        PickerHueBar = 33554432,
        PickerHueWheel = 67108864,
        PickerNoRotate = 134217728,
        InputRGB = 268435456,
        InputHSV = 536870912,
        DefaultOptions_ = 311427072,
        AlphaMask_ = 28674,
        DisplayMask_ = 7340032,
        DataTypeMask_ = 25165824,
        PickerMask_ = 100663296,
        InputMask_ = 805306368,
    }

    enum ImTextureStatus {
        OK = 0,
        Destroyed = 1,
        WantCreate = 2,
        WantUpdates = 3,
        WantDestroy = 4,
    }

    enum ImGuiContextHookType {
        NewFramePre = 0,
        NewFramePost = 1,
        EndFramePre = 2,
        EndFramePost = 3,
        RenderPre = 4,
        RenderPost = 5,
        Shutdown = 6,
        PendingRemoval_ = 7,
    }

    enum ImGuiTabBarFlags {
        None = 0,
        Reorderable = 1,
        AutoSelectNewTabs = 2,
        TabListPopupButton = 4,
        NoCloseWithMiddleMouseButton = 8,
        NoTabListScrollingButtons = 16,
        NoTooltip = 32,
        DrawSelectedOverline = 64,
        FittingPolicyMixed = 128,
        FittingPolicyShrink = 256,
        FittingPolicyScroll = 512,
        FittingPolicyMask_ = 896,
        FittingPolicyDefault_ = 128,
    }

    enum ImDrawListFlags {
        None = 0,
        AntiAliasedLines = 1,
        AntiAliasedLinesUseTex = 2,
        AntiAliasedFill = 4,
        AllowVtxOffset = 8,
        TextNoPixelSnap = 16,
    }

    enum ImGuiWindowBgClickFlags {
        None = 0,
        Move = 1,
    }

    enum ImGuiInputFlags {
        None = 0,
        Repeat = 1,
        RouteActive = 1024,
        RouteFocused = 2048,
        RouteGlobal = 4096,
        RouteAlways = 8192,
        RouteOverFocused = 16384,
        RouteOverActive = 32768,
        RouteUnlessBgFocused = 65536,
        RouteFromRootWindow = 131072,
        Tooltip = 262144,
    }

    enum ImGuiKey {
        None = 0,
        NamedKey_BEGIN = 512,
        Tab = 512,
        LeftArrow = 513,
        RightArrow = 514,
        UpArrow = 515,
        DownArrow = 516,
        PageUp = 517,
        PageDown = 518,
        Home = 519,
        End = 520,
        Insert = 521,
        Delete = 522,
        Backspace = 523,
        Space = 524,
        Enter = 525,
        Escape = 526,
        LeftCtrl = 527,
        LeftShift = 528,
        LeftAlt = 529,
        LeftSuper = 530,
        RightCtrl = 531,
        RightShift = 532,
        RightAlt = 533,
        RightSuper = 534,
        Menu = 535,
        n0 = 536,
        n1 = 537,
        n2 = 538,
        n3 = 539,
        n4 = 540,
        n5 = 541,
        n6 = 542,
        n7 = 543,
        n8 = 544,
        n9 = 545,
        A = 546,
        B = 547,
        C = 548,
        D = 549,
        E = 550,
        F = 551,
        G = 552,
        H = 553,
        I = 554,
        J = 555,
        K = 556,
        L = 557,
        M = 558,
        N = 559,
        O = 560,
        P = 561,
        Q = 562,
        R = 563,
        S = 564,
        T = 565,
        U = 566,
        V = 567,
        W = 568,
        X = 569,
        Y = 570,
        Z = 571,
        F1 = 572,
        F2 = 573,
        F3 = 574,
        F4 = 575,
        F5 = 576,
        F6 = 577,
        F7 = 578,
        F8 = 579,
        F9 = 580,
        F10 = 581,
        F11 = 582,
        F12 = 583,
        F13 = 584,
        F14 = 585,
        F15 = 586,
        F16 = 587,
        F17 = 588,
        F18 = 589,
        F19 = 590,
        F20 = 591,
        F21 = 592,
        F22 = 593,
        F23 = 594,
        F24 = 595,
        Apostrophe = 596,
        Comma = 597,
        Minus = 598,
        Period = 599,
        Slash = 600,
        Semicolon = 601,
        Equal = 602,
        LeftBracket = 603,
        Backslash = 604,
        RightBracket = 605,
        GraveAccent = 606,
        CapsLock = 607,
        ScrollLock = 608,
        NumLock = 609,
        PrintScreen = 610,
        Pause = 611,
        Keypad0 = 612,
        Keypad1 = 613,
        Keypad2 = 614,
        Keypad3 = 615,
        Keypad4 = 616,
        Keypad5 = 617,
        Keypad6 = 618,
        Keypad7 = 619,
        Keypad8 = 620,
        Keypad9 = 621,
        KeypadDecimal = 622,
        KeypadDivide = 623,
        KeypadMultiply = 624,
        KeypadSubtract = 625,
        KeypadAdd = 626,
        KeypadEnter = 627,
        KeypadEqual = 628,
        AppBack = 629,
        AppForward = 630,
        Oem102 = 631,
        GamepadStart = 632,
        GamepadBack = 633,
        GamepadFaceLeft = 634,
        GamepadFaceRight = 635,
        GamepadFaceUp = 636,
        GamepadFaceDown = 637,
        GamepadDpadLeft = 638,
        GamepadDpadRight = 639,
        GamepadDpadUp = 640,
        GamepadDpadDown = 641,
        GamepadL1 = 642,
        GamepadR1 = 643,
        GamepadL2 = 644,
        GamepadR2 = 645,
        GamepadL3 = 646,
        GamepadR3 = 647,
        GamepadLStickLeft = 648,
        GamepadLStickRight = 649,
        GamepadLStickUp = 650,
        GamepadLStickDown = 651,
        GamepadRStickLeft = 652,
        GamepadRStickRight = 653,
        GamepadRStickUp = 654,
        GamepadRStickDown = 655,
        MouseLeft = 656,
        MouseRight = 657,
        MouseMiddle = 658,
        MouseX1 = 659,
        MouseX2 = 660,
        MouseWheelX = 661,
        MouseWheelY = 662,
        ReservedForModCtrl = 663,
        ReservedForModShift = 664,
        ReservedForModAlt = 665,
        ReservedForModSuper = 666,
        NamedKey_END = 667,
        NamedKey_COUNT = 155,
        ImGuiMod_None = 0,
        ImGuiMod_Ctrl = 4096,
        ImGuiMod_Shift = 8192,
        ImGuiMod_Alt = 16384,
        ImGuiMod_Super = 32768,
        ImGuiMod_Mask_ = 61440,
    }

    enum ImGuiCond {
        None = 0,
        Always = 1,
        Once = 2,
        FirstUseEver = 4,
        Appearing = 8,
    }

    enum ImGuiSelectableFlags {
        None = 0,
        NoAutoClosePopups = 1,
        SpanAllColumns = 2,
        AllowDoubleClick = 4,
        Disabled = 8,
        AllowOverlap = 16,
        Highlight = 32,
        SelectOnNav = 64,
    }

    enum ImGuiNextWindowDataFlags {
        None = 0,
        HasPos = 1,
        HasSize = 2,
        HasContentSize = 4,
        HasCollapsed = 8,
        HasSizeConstraint = 16,
        HasFocus = 32,
        HasBgAlpha = 64,
        HasScroll = 128,
        HasWindowFlags = 256,
        HasChildFlags = 512,
        HasRefreshPolicy = 1024,
        HasViewport = 2048,
        HasDock = 4096,
        HasWindowClass = 8192,
    }

    enum ImGuiStyleVar {
        Alpha = 0,
        DisabledAlpha = 1,
        WindowPadding = 2,
        WindowRounding = 3,
        WindowBorderSize = 4,
        WindowMinSize = 5,
        WindowTitleAlign = 6,
        ChildRounding = 7,
        ChildBorderSize = 8,
        PopupRounding = 9,
        PopupBorderSize = 10,
        FramePadding = 11,
        FrameRounding = 12,
        FrameBorderSize = 13,
        ItemSpacing = 14,
        ItemInnerSpacing = 15,
        IndentSpacing = 16,
        CellPadding = 17,
        ScrollbarSize = 18,
        ScrollbarRounding = 19,
        ScrollbarPadding = 20,
        GrabMinSize = 21,
        GrabRounding = 22,
        ImageRounding = 23,
        ImageBorderSize = 24,
        TabRounding = 25,
        TabBorderSize = 26,
        TabMinWidthBase = 27,
        TabMinWidthShrink = 28,
        TabBarBorderSize = 29,
        TabBarOverlineSize = 30,
        TableAngledHeadersAngle = 31,
        TableAngledHeadersTextAlign = 32,
        TreeLinesSize = 33,
        TreeLinesRounding = 34,
        MenuItemRounding = 35,
        SelectableRounding = 36,
        DragDropTargetRounding = 37,
        ButtonTextAlign = 38,
        SelectableTextAlign = 39,
        SeparatorSize = 40,
        SeparatorTextBorderSize = 41,
        SeparatorTextAlign = 42,
        SeparatorTextPadding = 43,
        DockingSeparatorSize = 44,
        COUNT = 45,
    }

    enum ImGuiInputTextFlagsI : ImGuiInputTextFlags {
        Multiline = cast(ImGuiInputTextFlags)67108864,
        TempInput = cast(ImGuiInputTextFlags)134217728,
        LocalizeDecimalPoint = cast(ImGuiInputTextFlags)268435456,
    }

    enum ImGuiComboFlags {
        None = 0,
        PopupAlignLeft = 1,
        HeightSmall = 2,
        HeightRegular = 4,
        HeightLarge = 8,
        HeightLargest = 16,
        NoArrowButton = 32,
        NoPreview = 64,
        WidthFitPreview = 128,
        HeightMask_ = 30,
    }

    enum ImGuiItemFlagsI : ImGuiItemFlags {
        ReadOnly = cast(ImGuiItemFlags)2048,
        MixedValue = cast(ImGuiItemFlags)4096,
        NoWindowHoverableCheck = cast(ImGuiItemFlags)8192,
        AllowOverlap = cast(ImGuiItemFlags)16384,
        NoNavDisableMouseHover = cast(ImGuiItemFlags)32768,
        NoMarkEdited = cast(ImGuiItemFlags)65536,
        NoFocus = cast(ImGuiItemFlags)131072,
        Inputable = cast(ImGuiItemFlags)1048576,
        HasSelectionUserData = cast(ImGuiItemFlags)2097152,
        IsMultiSelect = cast(ImGuiItemFlags)4194304,
        Default_ = cast(ImGuiItemFlags)144,
    }

    enum ImFontAtlasFlags {
        None = 0,
        NoPowerOfTwoHeight = 1,
        NoMouseCursors = 2,
        NoBakedLines = 4,
    }

    enum ImGuiBackendFlags {
        None = 0,
        HasGamepad = 1,
        HasMouseCursors = 2,
        HasSetMousePos = 4,
        RendererHasVtxOffset = 8,
        RendererHasTextures = 16,
        RendererHasViewports = 1024,
        PlatformHasViewports = 2048,
        HasMouseHoveredViewport = 4096,
        HasParentViewport = 8192,
    }

    enum ImGuiWindowRefreshFlags {
        None = 0,
        TryToAvoidRefresh = 1,
        RefreshOnHover = 2,
        RefreshOnFocus = 4,
    }

    enum ImGuiItemFlags {
        None = 0,
        NoTabStop = 1,
        NoNav = 2,
        NoNavDefaultFocus = 4,
        ButtonRepeat = 8,
        AutoClosePopups = 16,
        AllowDuplicateId = 32,
        Disabled = 64,
        LiveEditOnInputText = 128,
        LiveEditOnInputScalar = 256,
        LiveEditOnInput = 384,
    }

    enum ImGuiLogFlags {
        None = 0,
        OutputTTY = 1,
        OutputFile = 2,
        OutputBuffer = 4,
        OutputClipboard = 8,
        OutputMask_ = 15,
    }

    enum ImGuiNavLayer {
        Main = 0,
        Menu = 1,
        COUNT = 2,
    }

    enum ImTextureFormat {
        RGBA32 = 0,
        Alpha8 = 1,
    }

    enum ImGuiDockNodeState {
        Unknown = 0,
        HostWindowHiddenBecauseSingleWindow = 1,
        HostWindowHiddenBecauseWindowsAreResizing = 2,
        HostWindowVisible = 3,
    }

    enum ImGuiAxis {
        None = -1,
        X = 0,
        Y = 1,
    }

    enum ImGuiButtonFlagsI : ImGuiButtonFlags {
        PressedOnClick = cast(ImGuiButtonFlags)16,
        PressedOnClickRelease = cast(ImGuiButtonFlags)32,
        PressedOnClickReleaseAnywhere = cast(ImGuiButtonFlags)64,
        PressedOnRelease = cast(ImGuiButtonFlags)128,
        PressedOnDoubleClick = cast(ImGuiButtonFlags)256,
        PressedOnDragDropHold = cast(ImGuiButtonFlags)512,
        FlattenChildren = cast(ImGuiButtonFlags)2048,
        AlignTextBaseLine = cast(ImGuiButtonFlags)32768,
        NoKeyModsAllowed = cast(ImGuiButtonFlags)65536,
        NoHoldingActiveId = cast(ImGuiButtonFlags)131072,
        NoNavFocus = cast(ImGuiButtonFlags)262144,
        NoHoveredOnFocus = cast(ImGuiButtonFlags)524288,
        NoSetKeyOwner = cast(ImGuiButtonFlags)1048576,
        NoTestKeyOwner = cast(ImGuiButtonFlags)2097152,
        NoFocus = cast(ImGuiButtonFlags)4194304,
        PressedOnMask_ = cast(ImGuiButtonFlags)1008,
        PressedOnDefault_ = cast(ImGuiButtonFlags)32,
    }

    enum ImGuiDragDropFlags {
        None = 0,
        SourceNoPreviewTooltip = 1,
        SourceNoDisableHover = 2,
        SourceNoHoldToOpenOthers = 4,
        SourceAllowNullID = 8,
        SourceExtern = 16,
        PayloadAutoExpire = 32,
        PayloadNoCrossContext = 64,
        PayloadNoCrossProcess = 128,
        AcceptBeforeDelivery = 1024,
        AcceptNoDrawDefaultRect = 2048,
        AcceptNoPreviewTooltip = 4096,
        AcceptDrawAsHovered = 8192,
        AcceptPeekOnly = 3072,
    }

    enum ImGuiListClipperFlags {
        None = 0,
        NoSetTableRowCounters = 1,
    }

    enum ImWcharClass {
        Blank = 0,
        Punct = 1,
        Other = 2,
    }

    enum ImGuiSelectionRequestType {
        None = 0,
        SetAll = 1,
        SetRange = 2,
    }

    enum ImGuiDebugLogFlags {
        None = 0,
        EventError = 1,
        EventActiveId = 2,
        EventFocus = 4,
        EventPopup = 8,
        EventNav = 16,
        EventClipper = 32,
        EventSelection = 64,
        EventIO = 128,
        EventFont = 256,
        EventInputRouting = 512,
        EventDocking = 1024,
        EventViewport = 2048,
        EventTable = 4096,
        EventMask_ = 8191,
        OutputToTTY = 1048576,
        OutputToDebugger = 2097152,
        OutputToTestEngine = 4194304,
    }

    enum ImGuiSortDirection {
        None = 0,
        Ascending = 1,
        Descending = 2,
    }

    enum ImGuiTableFlags {
        None = 0,
        Resizable = 1,
        Reorderable = 2,
        Hideable = 4,
        Sortable = 8,
        NoSavedSettings = 16,
        ContextMenuInBody = 32,
        RowBg = 64,
        BordersInnerH = 128,
        BordersOuterH = 256,
        BordersInnerV = 512,
        BordersOuterV = 1024,
        BordersH = 384,
        BordersV = 1536,
        BordersInner = 640,
        BordersOuter = 1280,
        Borders = 1920,
        NoBordersInBody = 2048,
        NoBordersInBodyUntilResize = 4096,
        SizingFixedFit = 8192,
        SizingFixedSame = 16384,
        SizingStretchProp = 24576,
        SizingStretchSame = 32768,
        NoHostExtendX = 65536,
        NoHostExtendY = 131072,
        NoKeepColumnsVisible = 262144,
        PreciseWidths = 524288,
        NoClip = 1048576,
        PadOuterX = 2097152,
        NoPadOuterX = 4194304,
        NoPadInnerX = 8388608,
        ScrollX = 16777216,
        ScrollY = 33554432,
        SortMulti = 67108864,
        SortTristate = 134217728,
        HighlightHoveredColumn = 268435456,
        SizingMask_ = 57344,
    }

    enum ImGuiDir {
        None = -1,
        Left = 0,
        Right = 1,
        Up = 2,
        Down = 3,
        COUNT = 4,
    }

    enum ImGuiScrollFlags {
        None = 0,
        KeepVisibleEdgeX = 1,
        KeepVisibleEdgeY = 2,
        KeepVisibleCenterX = 4,
        KeepVisibleCenterY = 8,
        AlwaysCenterX = 16,
        AlwaysCenterY = 32,
        NoScrollParent = 64,
        MaskX_ = 21,
        MaskY_ = 42,
    }

    enum ImGuiTreeNodeFlagsI : ImGuiTreeNodeFlags {
        NoNavFocus = cast(ImGuiTreeNodeFlags)134217728,
        ClipLabelForTrailingButton = cast(ImGuiTreeNodeFlags)268435456,
        UpsideDownArrow = cast(ImGuiTreeNodeFlags)536870912,
        OpenOnMask_ = cast(ImGuiTreeNodeFlags)192,
        DrawLinesMask_ = cast(ImGuiTreeNodeFlags)1835008,
    }

    enum ImDrawFlags {
        None = 0,
        RoundCornersTopLeft = 16,
        RoundCornersTopRight = 32,
        RoundCornersBottomLeft = 64,
        RoundCornersBottomRight = 128,
        RoundCornersNone = 256,
        RoundCornersAll = 240,
        RoundCornersDefault_ = 240,
        RoundCornersTop = 48,
        RoundCornersBottom = 192,
        RoundCornersLeft = 80,
        RoundCornersRight = 160,
        RoundCornersMask_ = 496,
        Closed = 512,
        InvalidMask_ = -2147483633,
    }

    enum ImGuiFocusedFlags {
        None = 0,
        ChildWindows = 1,
        RootWindow = 2,
        AnyWindow = 4,
        NoPopupHierarchy = 8,
        DockHierarchy = 16,
        RootAndChildWindows = 3,
    }

    enum ImGuiTabItemFlagsI : ImGuiTabItemFlags {
        SectionMask_ = cast(ImGuiTabItemFlags)192,
        NoCloseButton = cast(ImGuiTabItemFlags)1048576,
        Button = cast(ImGuiTabItemFlags)2097152,
        Invisible = cast(ImGuiTabItemFlags)4194304,
        Unsorted = cast(ImGuiTabItemFlags)8388608,
    }

    enum ImGuiSliderFlags {
        None = 0,
        Logarithmic = 32,
        NoRoundToFormat = 64,
        NoInput = 128,
        WrapAround = 256,
        ClampOnInput = 512,
        ClampZeroRange = 1024,
        NoSpeedTweaks = 2048,
        ColorMarkers = 4096,
        AlwaysClamp = 1536,
        InvalidMask_ = 1879048207,
    }

    enum ImGuiDataType {
        S8 = 0,
        U8 = 1,
        S16 = 2,
        U16 = 3,
        S32 = 4,
        U32 = 5,
        S64 = 6,
        U64 = 7,
        Float = 8,
        Double = 9,
        Bool = 10,
        String = 11,
        COUNT = 12,
    }

    enum ImGuiComboFlagsI : ImGuiComboFlags {
        CustomPreview = cast(ImGuiComboFlags)1048576,
    }

    enum ImGuiCol {
        Text = 0,
        TextDisabled = 1,
        WindowBg = 2,
        ChildBg = 3,
        PopupBg = 4,
        Border = 5,
        BorderShadow = 6,
        FrameBg = 7,
        FrameBgHovered = 8,
        FrameBgActive = 9,
        TitleBg = 10,
        TitleBgActive = 11,
        TitleBgCollapsed = 12,
        MenuBarBg = 13,
        ScrollbarBg = 14,
        ScrollbarGrab = 15,
        ScrollbarGrabHovered = 16,
        ScrollbarGrabActive = 17,
        CheckMark = 18,
        CheckboxSelectedBg = 19,
        SliderGrab = 20,
        SliderGrabActive = 21,
        Button = 22,
        ButtonHovered = 23,
        ButtonActive = 24,
        Header = 25,
        HeaderHovered = 26,
        HeaderActive = 27,
        Separator = 28,
        SeparatorHovered = 29,
        SeparatorActive = 30,
        ResizeGrip = 31,
        ResizeGripHovered = 32,
        ResizeGripActive = 33,
        InputTextCursor = 34,
        TabHovered = 35,
        Tab = 36,
        TabSelected = 37,
        TabSelectedOverline = 38,
        TabDimmed = 39,
        TabDimmedSelected = 40,
        TabDimmedSelectedOverline = 41,
        DockingPreview = 42,
        DockingEmptyBg = 43,
        PlotLines = 44,
        PlotLinesHovered = 45,
        PlotHistogram = 46,
        PlotHistogramHovered = 47,
        TableHeaderBg = 48,
        TableBorderStrong = 49,
        TableBorderLight = 50,
        TableRowBg = 51,
        TableRowBgAlt = 52,
        TextLink = 53,
        TextSelectedBg = 54,
        TreeLines = 55,
        DragDropTarget = 56,
        DragDropTargetBg = 57,
        UnsavedMarker = 58,
        NavCursor = 59,
        NavWindowingHighlight = 60,
        NavWindowingDimBg = 61,
        ModalWindowDimBg = 62,
        COUNT = 63,
    }

    enum ImGuiButtonFlags {
        None = 0,
        MouseButtonLeft = 1,
        MouseButtonRight = 2,
        MouseButtonMiddle = 4,
        MouseButtonMask_ = 7,
        EnableNav = 8,
        AllowOverlap = 4096,
    }

    enum ImGuiViewportFlags {
        None = 0,
        IsPlatformWindow = 1,
        IsPlatformMonitor = 2,
        OwnedByApp = 4,
        NoDecoration = 8,
        NoTaskBarIcon = 16,
        NoFocusOnAppearing = 32,
        NoFocusOnClick = 64,
        NoInputs = 128,
        NoRendererClear = 256,
        NoAutoMerge = 512,
        TopMost = 1024,
        CanHostOtherWindows = 2048,
        IsMinimized = 4096,
        IsFocused = 8192,
    }

    enum ImGuiSelectableFlagsI : ImGuiSelectableFlags {
        NoHoldingActiveID = cast(ImGuiSelectableFlags)1048576,
        SelectOnClick = cast(ImGuiSelectableFlags)4194304,
        SelectOnRelease = cast(ImGuiSelectableFlags)8388608,
        SpanAvailWidth = cast(ImGuiSelectableFlags)16777216,
        SetNavIdOnHover = cast(ImGuiSelectableFlags)33554432,
        NoPadWithHalfSpacing = cast(ImGuiSelectableFlags)67108864,
        NoSetKeyOwner = cast(ImGuiSelectableFlags)134217728,
    }

    enum ImGuiInputSource {
        None = 0,
        Mouse = 1,
        Keyboard = 2,
        Gamepad = 3,
        COUNT = 4,
    }

    enum ImGuiMouseCursor {
        None = -1,
        Arrow = 0,
        TextInput = 1,
        ResizeAll = 2,
        ResizeNS = 3,
        ResizeEW = 4,
        ResizeNESW = 5,
        ResizeNWSE = 6,
        Hand = 7,
        Wait = 8,
        Progress = 9,
        NotAllowed = 10,
        COUNT = 11,
    }

    enum ImGuiMultiSelectFlags {
        None = 0,
        SingleSelect = 1,
        NoSelectAll = 2,
        NoRangeSelect = 4,
        NoAutoSelect = 8,
        NoAutoClear = 16,
        NoAutoClearOnReselect = 32,
        BoxSelect1d = 64,
        BoxSelect2d = 128,
        BoxSelectNoScroll = 256,
        ClearOnEscape = 512,
        ClearOnClickVoid = 1024,
        ScopeWindow = 2048,
        ScopeRect = 4096,
        SelectOnAuto = 8192,
        SelectOnClickAlways = 16384,
        SelectOnClickRelease = 32768,
        NavWrapX = 65536,
        NoSelectOnRightClick = 131072,
        SelectOnMask_ = 57344,
        CheckboxMode_ = 1048576,
    }

    enum ImGuiNavRenderCursorFlags {
        None = 0,
        Compact = 2,
        AlwaysDraw = 4,
    }

    enum ImGuiDockNodeFlags {
        None = 0,
        KeepAliveOnly = 1,
        NoDockingOverCentralNode = 4,
        PassthruCentralNode = 8,
        NoDockingSplit = 16,
        NoResize = 32,
        AutoHideTabBar = 64,
        NoUndocking = 128,
    }

    enum ImGuiInputTextFlags {
        None = 0,
        CharsDecimal = 1,
        CharsHexadecimal = 2,
        CharsScientific = 4,
        CharsUppercase = 8,
        CharsNoBlank = 16,
        AllowTabInput = 32,
        EnterReturnsTrue = 64,
        EscapeClearsAll = 128,
        CtrlEnterForNewLine = 256,
        ReadOnly = 512,
        Password = 1024,
        AlwaysOverwrite = 2048,
        AutoSelectAll = 4096,
        ParseEmptyRefVal = 8192,
        DisplayEmptyRefVal = 16384,
        NoHorizontalScroll = 32768,
        NoUndoRedo = 65536,
        ElideLeft = 131072,
        CallbackCompletion = 262144,
        CallbackHistory = 524288,
        CallbackAlways = 1048576,
        CallbackCharFilter = 2097152,
        CallbackResize = 4194304,
        CallbackEdit = 8388608,
        WordWrap = 16777216,
    }

    enum ImGuiPopupFlags {
        None = 0,
        MouseButtonLeft = 4,
        MouseButtonRight = 8,
        MouseButtonMiddle = 12,
        NoReopen = 32,
        NoOpenOverExistingPopup = 128,
        NoOpenOverItems = 256,
        AnyPopupId = 1024,
        AnyPopupLevel = 2048,
        AnyPopup = 3072,
        MouseButtonShift_ = 2,
        MouseButtonMask_ = 12,
        InvalidMask_ = 3,
    }

    enum ImFontFlags {
        None = 0,
        NoLoadError = 2,
        NoLoadGlyphs = 4,
        LockBakedSizes = 8,
        ImplicitRefSize = 16,
    }

    enum ImGuiActivateFlags {
        None = 0,
        PreferInput = 1,
        PreferTweak = 2,
        TryToPreserveState = 4,
        FromTabbing = 8,
        FromShortcut = 16,
        FromFocusApi = 32,
    }

    enum ImGuiHoveredFlags {
        None = 0,
        ChildWindows = 1,
        RootWindow = 2,
        AnyWindow = 4,
        NoPopupHierarchy = 8,
        DockHierarchy = 16,
        AllowWhenBlockedByPopup = 32,
        AllowWhenBlockedByActiveItem = 128,
        AllowWhenOverlappedByItem = 256,
        AllowWhenOverlappedByWindow = 512,
        AllowWhenDisabled = 1024,
        NoNavOverride = 2048,
        AllowWhenOverlapped = 768,
        RectOnly = 928,
        RootAndChildWindows = 3,
        ForTooltip = 4096,
        Stationary = 8192,
        DelayNone = 16384,
        DelayShort = 32768,
        DelayNormal = 65536,
        NoSharedDelay = 131072,
    }


    struct StbTexteditRow {
        float x0;
        float x1;
        float baseline_y_delta;
        float ymin;
        float ymax;
        int num_chars;
    }

    struct ImGuiInputEventText {
        uint Char;
    }

    struct ImGuiStackLevelInfo {
        ImGuiID ID;
        ImS8 QueryFrameCount;
        bool QuerySuccess;
        ImS8 DataType;
        int DescOffset;
    }

    struct ImGuiWindowStackData {
        ImGuiWindow* Window;
        ImGuiLastItemData ParentLastItemDataBackup;
        ImGuiErrorRecoveryState StackSizesInBegin;
        bool DisabledOverrideReenable;
        float DisabledOverrideReenableAlphaBackup;
    }

    struct ImGuiKeyRoutingData {
        ImGuiKeyRoutingIndex NextEntryIndex;
        ImU16 Mods;
        ImU16 RoutingCurrScore;
        ImU16 RoutingNextScore;
        ImGuiID RoutingCurr;
        ImGuiID RoutingNext;
    }

    struct ImGuiTableTempData {
        ImGuiID WindowID;
        int TableIndex;
        float LastTimeActive;
        float AngledHeadersExtraWidth;
        ImVector!(ImGuiTableHeaderData) AngledHeadersRequests;
        ImVector!(ImGuiTableReconcileColumnData) ReconcileColumnsRequests;
        void* OldColumnsRawData;
        ImSpan!(ImGuiTableColumn) OldColumnsData;
        ImVec2 UserOuterSize;
        ImDrawListSplitter DrawSplitter;
        ImRect HostBackupWorkRect;
        ImRect HostBackupParentWorkRect;
        ImVec2 HostBackupPrevLineSize;
        ImVec2 HostBackupCurrLineSize;
        ImVec2 HostBackupCursorMaxPos;
        ImVec1 HostBackupColumnsOffset;
        float HostBackupItemWidth;
        int HostBackupItemWidthStackSize;
    }

    struct ImGuiDataTypeInfo {
        size_t Size;
        const(char)* Name;
        const(char)* PrintFmt;
        const(char)* ScanFmt;
    }

    struct ImGuiPopupData {
        ImGuiID PopupId;
        ImGuiWindow* Window;
        ImGuiWindow* RestoreNavWindow;
        int ParentNavLayer;
        int OpenFrameCount;
        ImGuiID OpenParentId;
        ImVec2 OpenPopupPos;
        ImVec2 OpenMousePos;
    }

    struct ImGuiWindow {
        ImGuiContext* Ctx;
        char* Name;
        ImGuiID ID;
        ImGuiWindowFlags Flags;
        ImGuiWindowFlags FlagsPreviousFrame;
        ImGuiChildFlags ChildFlags;
        ImGuiWindowClass WindowClass;
        ImGuiViewportP* Viewport;
        ImGuiID ViewportId;
        ImVec2 ViewportPos;
        int ViewportAllowPlatformMonitorExtend;
        ImVec2 Pos;
        ImVec2 Size;
        ImVec2 SizeFull;
        ImVec2 ContentSize;
        ImVec2 ContentSizeIdeal;
        ImVec2 ContentSizeExplicit;
        ImVec2 WindowPadding;
        float WindowRounding;
        float WindowBorderSize;
        float TitleBarHeight;
        float MenuBarHeight;
        float DecoOuterSizeX1;
        float DecoOuterSizeY1;
        float DecoOuterSizeX2;
        float DecoOuterSizeY2;
        float DecoInnerSizeX1;
        float DecoInnerSizeY1;
        int NameBufLen;
        ImGuiID MoveId;
        ImGuiID TabId;
        ImGuiID ChildId;
        ImGuiID PopupId;
        ImVec2 Scroll;
        ImVec2 ScrollMax;
        ImVec2 ScrollTarget;
        ImVec2 ScrollTargetCenterRatio;
        ImVec2 ScrollTargetEdgeSnapDist;
        ImVec2 ScrollbarSizes;
        bool ScrollbarX;
        bool ScrollbarY;
        bool ScrollbarXStabilizeEnabled;
        ImU8 ScrollbarXStabilizeToggledHistory;
        bool ViewportOwned;
        bool Active;
        bool WasActive;
        bool WriteAccessed;
        bool Collapsed;
        bool WantCollapseToggle;
        bool SkipItems;
        bool SkipRefresh;
        bool Appearing;
        bool Hidden;
        bool IsFallbackWindow;
        bool IsExplicitChild;
        bool HasCloseButton;
        byte ResizeBorderHovered;
        byte ResizeBorderHeld;
        short BeginCount;
        short BeginCountPreviousFrame;
        short BeginOrderWithinParent;
        short BeginOrderWithinContext;
        short FocusOrder;
        ImGuiDir AutoPosLastDirection;
        ImS8 AutoFitFramesX;
        ImS8 AutoFitFramesY;
        bool AutoFitOnlyGrows;
        ImS8 HiddenFramesCanSkipItems;
        ImS8 HiddenFramesCannotSkipItems;
        ImS8 HiddenFramesForRenderOnly;
        ImS8 DisableInputsFrames;
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImGuiWindowBgClickFlags BgClickFlags : 8;
        ImGuiWindowBgClickFlags bitfield_0;
        @property ImGuiWindowBgClickFlags BgClickFlags() { return GetValue!ImGuiWindowBgClickFlags(bitfield_0, 0, 8); }
        @property void BgClickFlags(ImGuiWindowBgClickFlags aValue) { bitfield_0 = SetValue(bitfield_0, 0, 8, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 8.sizeof);
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImGuiCond SetWindowPosAllowFlags : 8;
        //ImGuiCond SetWindowSizeAllowFlags : 8;
        //ImGuiCond SetWindowCollapsedAllowFlags : 8;
        //ImGuiCond SetWindowDockAllowFlags : 8;
        ImGuiCond bitfield_1;
        @property ImGuiCond SetWindowPosAllowFlags() { return GetValue!ImGuiCond(bitfield_1, 0, 8); }
        @property void SetWindowPosAllowFlags(ImGuiCond aValue) { bitfield_1 = SetValue(bitfield_1, 0, 8, aValue); };
        @property ImGuiCond SetWindowSizeAllowFlags() { return GetValue!ImGuiCond(bitfield_1, 8, 8); }
        @property void SetWindowSizeAllowFlags(ImGuiCond aValue) { bitfield_1 = SetValue(bitfield_1, 8, 8, aValue); };
        @property ImGuiCond SetWindowCollapsedAllowFlags() { return GetValue!ImGuiCond(bitfield_1, 16, 8); }
        @property void SetWindowCollapsedAllowFlags(ImGuiCond aValue) { bitfield_1 = SetValue(bitfield_1, 16, 8, aValue); };
        @property ImGuiCond SetWindowDockAllowFlags() { return GetValue!ImGuiCond(bitfield_1, 24, 8); }
        @property void SetWindowDockAllowFlags(ImGuiCond aValue) { bitfield_1 = SetValue(bitfield_1, 24, 8, aValue); };
        static assert((bitfield_1.sizeof * 8) >= 32.sizeof);
        ImVec2 SetWindowPosVal;
        ImVec2 SetWindowPosPivot;
        ImVector!(ImGuiID) IDStack;
        ImGuiWindowTempData DC;
        ImRect OuterRectClipped;
        ImRect InnerRect;
        ImRect InnerClipRect;
        ImRect WorkRect;
        ImRect ParentWorkRect;
        ImRect ClipRect;
        ImRect ContentRegionRect;
        ImVec2ih HitTestHoleSize;
        ImVec2ih HitTestHoleOffset;
        int LastFrameActive;
        int LastFrameJustFocused;
        float LastTimeActive;
        ImGuiStorage StateStorage;
        ImVector!(ImGuiOldColumns) ColumnsStorage;
        float FontWindowScale;
        float FontWindowScaleParents;
        float FontRefSize;
        int SettingsOffset;
        ImDrawList* DrawList;
        ImDrawList DrawListInst;
        ImGuiWindow* ParentWindow;
        ImGuiWindow* ParentWindowInBeginStack;
        ImGuiWindow* RootWindow;
        ImGuiWindow* RootWindowPopupTree;
        ImGuiWindow* RootWindowDockTree;
        ImGuiWindow* RootWindowForTitleBarHighlight;
        ImGuiWindow* RootWindowForNav;
        ImGuiWindow* ParentWindowForFocusRoute;
        ImGuiWindow* NavLastChildNavWindow;
        ImGuiID[ImGuiNavLayer.COUNT] NavLastIds;
        ImRect[ImGuiNavLayer.COUNT] NavRectRel;
        ImVec2[ImGuiNavLayer.COUNT] NavPreferredScoringPosRel;
        ImGuiID NavRootFocusScopeId;
        int MemoryDrawListIdxCapacity;
        int MemoryDrawListVtxCapacity;
        bool MemoryCompacted;
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //bool DockIsActive : 1;
        //bool DockNodeIsVisible : 1;
        //bool DockTabIsVisible : 1;
        //bool DockTabWantClose : 1;
        bool bitfield_2;
        @property bool DockIsActive() { return GetValue!bool(bitfield_2, 0, 1); }
        @property void DockIsActive(bool aValue) { bitfield_2 = SetValue(bitfield_2, 0, 1, aValue); };
        @property bool DockNodeIsVisible() { return GetValue!bool(bitfield_2, 1, 1); }
        @property void DockNodeIsVisible(bool aValue) { bitfield_2 = SetValue(bitfield_2, 1, 1, aValue); };
        @property bool DockTabIsVisible() { return GetValue!bool(bitfield_2, 2, 1); }
        @property void DockTabIsVisible(bool aValue) { bitfield_2 = SetValue(bitfield_2, 2, 1, aValue); };
        @property bool DockTabWantClose() { return GetValue!bool(bitfield_2, 3, 1); }
        @property void DockTabWantClose(bool aValue) { bitfield_2 = SetValue(bitfield_2, 3, 1, aValue); };
        static assert((bitfield_2.sizeof * 8) >= 4.sizeof);
        short DockOrder;
        ImGuiWindowDockStyle DockStyle;
        ImGuiDockNode* DockNode;
        ImGuiDockNode* DockNodeAsHost;
        ImGuiID DockId;
    }

    struct StbUndoRecord {
        int where;
        int insert_length;
        int delete_length;
        int char_storage;
    }

    struct ImGuiKeyRoutingTable {
        ImGuiKeyRoutingIndex[ImGuiKey.NamedKey_COUNT] Index;
        ImVector!(ImGuiKeyRoutingData) Entries;
        ImVector!(ImGuiKeyRoutingData) EntriesNext;
    }

    struct ImGuiErrorRecoveryState {
        short SizeOfWindowStack;
        short SizeOfIDStack;
        short SizeOfTreeStack;
        short SizeOfColorStack;
        short SizeOfStyleVarStack;
        short SizeOfFontStack;
        short SizeOfFocusScopeStack;
        short SizeOfGroupStack;
        short SizeOfItemFlagsStack;
        short SizeOfBeginPopupStack;
        short SizeOfDisabledStack;
    }

    struct ImGuiOldColumnData {
        float OffsetNorm;
        float OffsetNormBeforeResize;
        ImGuiOldColumnFlags Flags;
        ImRect ClipRect;
    }

    struct ImGuiTable {
        ImGuiID ID;
        ImGuiTableFlags Flags;
        void* RawData;
        ImGuiTableTempData* TempData;
        ImSpan!(ImGuiTableColumn) Columns;
        ImSpan!(ImGuiTableColumnIdx) DisplayOrderToIndex;
        ImSpan!(ImGuiTableCellData) RowCellData;
        ImBitArrayPtr EnabledMaskByDisplayOrder;
        ImBitArrayPtr EnabledMaskByIndex;
        ImBitArrayPtr VisibleMaskByIndex;
        ImGuiTableFlags SettingsLoadedFlags;
        int SettingsOffset;
        int LastFrameActive;
        int ColumnsCount;
        int CurrentRow;
        int CurrentColumn;
        ImS16 InstanceCurrent;
        ImS16 InstanceInteracted;
        float RowPosY1;
        float RowPosY2;
        float RowMinHeight;
        float RowCellPaddingY;
        float RowTextBaseline;
        float RowIndentOffsetX;
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImGuiTableRowFlags RowFlags : 16;
        //ImGuiTableRowFlags LastRowFlags : 16;
        ImGuiTableRowFlags bitfield_0;
        @property ImGuiTableRowFlags RowFlags() { return GetValue!ImGuiTableRowFlags(bitfield_0, 0, 16); }
        @property void RowFlags(ImGuiTableRowFlags aValue) { bitfield_0 = SetValue(bitfield_0, 0, 16, aValue); };
        @property ImGuiTableRowFlags LastRowFlags() { return GetValue!ImGuiTableRowFlags(bitfield_0, 16, 16); }
        @property void LastRowFlags(ImGuiTableRowFlags aValue) { bitfield_0 = SetValue(bitfield_0, 16, 16, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 32.sizeof);
        int RowBgColorCounter;
        ImU32[2] RowBgColor;
        ImU32 BorderColorStrong;
        ImU32 BorderColorLight;
        float BorderX1;
        float BorderX2;
        float HostIndentX;
        float MinColumnWidth;
        float OuterPaddingX;
        float CellPaddingX;
        float CellSpacingX1;
        float CellSpacingX2;
        float InnerWidth;
        float ColumnsGivenWidth;
        float ColumnsAutoFitWidth;
        float ColumnsStretchSumWeights;
        float ResizedColumnNextWidth;
        float ResizeLockMinContentsX2;
        float RefScale;
        float AngledHeadersHeight;
        float AngledHeadersSlope;
        ImRect OuterRect;
        ImRect InnerRect;
        ImRect WorkRect;
        ImRect InnerClipRect;
        ImRect BgClipRect;
        ImRect Bg0ClipRectForDrawCmd;
        ImRect Bg2ClipRectForDrawCmd;
        ImRect HostClipRect;
        ImRect HostBackupInnerClipRect;
        ImGuiWindow* OuterWindow;
        ImGuiWindow* InnerWindow;
        ImGuiTextBuffer ColumnsNames;
        ImDrawListSplitter* DrawSplitter;
        ImGuiTableInstanceData InstanceDataFirst;
        ImVector!(ImGuiTableInstanceData) InstanceDataExtra;
        ImGuiTableColumnSortSpecs SortSpecsSingle;
        ImVector!(ImGuiTableColumnSortSpecs) SortSpecsMulti;
        ImGuiTableSortSpecs SortSpecs;
        ImGuiTableColumnIdx SortSpecsCount;
        ImGuiTableColumnIdx ColumnsEnabledCount;
        ImGuiTableColumnIdx ColumnsEnabledFixedCount;
        ImGuiTableColumnIdx DeclColumnsCount;
        ImGuiTableColumnIdx AngledHeadersCount;
        ImGuiTableColumnIdx HoveredColumnBody;
        ImGuiTableColumnIdx HoveredColumnBorder;
        ImGuiTableColumnIdx HighlightColumnHeader;
        ImGuiTableColumnIdx AutoFitSingleColumn;
        ImGuiTableColumnIdx ResizedColumn;
        ImGuiTableColumnIdx LastResizedColumn;
        ImGuiTableColumnIdx HeldHeaderColumn;
        ImGuiTableColumnIdx LastHeldHeaderColumn;
        ImGuiTableColumnIdx ReorderColumn;
        ImGuiTableColumnIdx ReorderColumnDstOrder;
        ImGuiTableColumnIdx LeftMostEnabledColumn;
        ImGuiTableColumnIdx RightMostEnabledColumn;
        ImGuiTableColumnIdx LeftMostStretchedColumn;
        ImGuiTableColumnIdx RightMostStretchedColumn;
        ImGuiTableColumnIdx ContextPopupColumn;
        ImGuiTableColumnIdx FreezeRowsRequest;
        ImGuiTableColumnIdx FreezeRowsCount;
        ImGuiTableColumnIdx FreezeColumnsRequest;
        ImGuiTableColumnIdx FreezeColumnsCount;
        ImGuiTableColumnIdx RowCellDataCurrent;
        ImGuiTableDrawChannelIdx DummyDrawChannel;
        ImGuiTableDrawChannelIdx Bg2DrawChannelCurrent;
        ImGuiTableDrawChannelIdx Bg2DrawChannelUnfrozen;
        ImS8 NavLayer;
        bool IsLayoutLocked;
        bool IsInsideRow;
        bool IsInitializing;
        bool IsReconcileMode;
        bool IsSortSpecsDirty;
        bool IsUsingHeaders;
        bool IsContextPopupOpen;
        bool DisableDefaultContextMenu;
        bool IsSettingsRequestLoad;
        bool IsSettingsDirty;
        bool IsDefaultDisplayOrder;
        bool IsDefaultVisibility;
        bool IsResetAllRequest;
        bool IsResetDisplayOrderRequest;
        bool IsResetVisibilityRequest;
        bool IsUnfrozenRows;
        bool IsDefaultSizingPolicy;
        bool IsActiveIdAliveBeforeTable;
        bool IsActiveIdInTable;
        bool HasScrollbarYCurr;
        bool HasScrollbarYPrev;
        bool MemoryCompacted;
        bool HostSkipItems;
    }

    struct ImFontAtlasRect {
        ushort x;
        ushort y;
        ushort w;
        ushort h;
        ImVec2 uv0;
        ImVec2 uv1;
    }

    struct ImGuiWindowTempData {
        ImVec2 CursorPos;
        ImVec2 CursorPosPrevLine;
        ImVec2 CursorStartPos;
        ImVec2 CursorMaxPos;
        ImVec2 IdealMaxPos;
        ImVec2 CurrLineSize;
        ImVec2 PrevLineSize;
        float CurrLineTextBaseOffset;
        float PrevLineTextBaseOffset;
        bool IsSameLine;
        bool IsSetPos;
        ImVec1 Indent;
        ImVec1 ColumnsOffset;
        ImVec1 GroupOffset;
        ImVec2 CursorStartPosLossyness;
        ImGuiNavLayer NavLayerCurrent;
        short NavLayersActiveMask;
        short NavLayersActiveMaskNext;
        bool NavIsScrollPushableX;
        bool NavHideHighlightOneFrame;
        bool NavWindowHasScrollY;
        bool MenuBarAppending;
        ImVec2 MenuBarOffset;
        ImGuiMenuColumns MenuColumns;
        int TreeDepth;
        ImU32 TreeHasStackDataDepthMask;
        ImU32 TreeRecordsClippedNodesY2Mask;
        ImVector!(ImGuiWindow*) ChildWindows;
        ImGuiStorage* StateStorage;
        ImGuiOldColumns* CurrentColumns;
        int CurrentTableIdx;
        ImGuiLayoutType LayoutType;
        ImGuiLayoutType ParentLayoutType;
        ImU32 ModalDimBgColor;
        ImGuiItemStatusFlags WindowItemStatusFlags;
        ImGuiItemStatusFlags ChildItemStatusFlags;
        ImGuiItemStatusFlags DockTabItemStatusFlags;
        ImRect DockTabItemRect;
        float ItemWidth;
        float ItemWidthDefault;
        float TextWrapPos;
        ImVector!(float) ItemWidthStack;
        ImVector!(float) TextWrapPosStack;
    }

    struct ImGuiSelectionExternalStorage {
        void* UserData;
        void function(ImGuiSelectionExternalStorage* self,int idx,bool selected) AdapterSetItemSelected;
    }

    struct ImFontGlyph {
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //uint Colored : 1;
        //uint Visible : 1;
        //uint SourceIdx : 4;
        //uint Codepoint : 26;
        uint bitfield_0;
        @property uint Colored() { return GetValue!uint(bitfield_0, 0, 1); }
        @property void Colored(uint aValue) { bitfield_0 = SetValue(bitfield_0, 0, 1, aValue); };
        @property uint Visible() { return GetValue!uint(bitfield_0, 1, 1); }
        @property void Visible(uint aValue) { bitfield_0 = SetValue(bitfield_0, 1, 1, aValue); };
        @property uint SourceIdx() { return GetValue!uint(bitfield_0, 2, 4); }
        @property void SourceIdx(uint aValue) { bitfield_0 = SetValue(bitfield_0, 2, 4, aValue); };
        @property uint Codepoint() { return GetValue!uint(bitfield_0, 6, 26); }
        @property void Codepoint(uint aValue) { bitfield_0 = SetValue(bitfield_0, 6, 26, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 32.sizeof);
        float AdvanceX;
        float X0;
        float Y0;
        float X1;
        float Y1;
        float U0;
        float V0;
        float U1;
        float V1;
        int PackId;
    }

    struct ImGuiNextItemData {
        ImGuiNextItemDataFlags HasFlags;
        ImGuiItemFlags ItemFlagsSet;
        ImGuiID FocusScopeId;
        ImGuiSelectionUserData SelectionUserData;
        float Width;
        ImGuiKeyChord Shortcut;
        ImGuiInputFlags ShortcutFlags;
        bool OpenVal;
        ImU8 OpenCond;
        ImGuiDataTypeStorage RefVal;
        ImGuiID StorageId;
        ImU32 ColorMarker;
    }

    struct ImGuiStyleVarInfo {
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImU32 Count : 8;
        ImU32 bitfield_0;
        @property ImU32 Count() { return GetValue!ImU32(bitfield_0, 0, 8); }
        @property void Count(ImU32 aValue) { bitfield_0 = SetValue(bitfield_0, 0, 8, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 8.sizeof);
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImGuiDataType DataType : 8;
        ImGuiDataType bitfield_1;
        @property ImGuiDataType DataType() { return GetValue!ImGuiDataType(bitfield_1, 0, 8); }
        @property void DataType(ImGuiDataType aValue) { bitfield_1 = SetValue(bitfield_1, 0, 8, aValue); };
        static assert((bitfield_1.sizeof * 8) >= 8.sizeof);
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImU32 Offset : 16;
        ImU32 bitfield_2;
        @property ImU32 Offset() { return GetValue!ImU32(bitfield_2, 0, 16); }
        @property void Offset(ImU32 aValue) { bitfield_2 = SetValue(bitfield_2, 0, 16, aValue); };
        static assert((bitfield_2.sizeof * 8) >= 16.sizeof);
    }

    struct ImGuiTextRange {
        const(char)* b;
        const(char)* e;
    }

    struct ImGuiDebugItemPathQuery {
        ImGuiID MainID;
        bool Active;
        bool Complete;
        ImS8 Step;
        ImVector!(ImGuiStackLevelInfo) Results;
        ImGuiTextBuffer ResultsDescBuf;
        ImGuiTextBuffer ResultPathBuf;
    }

    struct ImGuiTypingSelectRequest {
        ImGuiTypingSelectFlags Flags;
        int SearchBufferLen;
        const(char)* SearchBuffer;
        bool SelectRequest;
        bool SingleCharMode;
        ImS8 SingleCharSize;
    }

    struct ImDrawDataBuilder {
        ImVector!(ImDrawList*)*[2] Layers;
        ImVector!(ImDrawList*) LayerData1;
    }

    struct ImGuiInputEventMouseWheel {
        float WheelX;
        float WheelY;
        ImGuiMouseSource MouseSource;
    }

    struct ImGuiKeyData {
        bool Down;
        float DownDuration;
        float DownDurationPrev;
        float AnalogValue;
    }

    struct ImGuiMultiSelectState {
        ImGuiWindow* Window;
        ImGuiID ID;
        int LastFrameActive;
        int LastSelectionSize;
        ImS8 RangeSelected;
        ImS8 NavIdSelected;
        ImGuiSelectionUserData RangeSrcItem;
        ImGuiSelectionUserData NavIdItem;
    }

    struct ImGuiListClipperRange {
        int Min;
        int Max;
        bool PosToIndexConvert;
        ImS8 PosToIndexOffsetMin;
        ImS8 PosToIndexOffsetMax;
    }

    struct ImFont {
        ImFontBaked* LastBaked;
        ImFontAtlas* OwnerAtlas;
        ImFontFlags Flags;
        float CurrentRasterizerDensity;
        ImGuiID FontId;
        float LegacySize;
        ImVector!(ImFontConfig*) Sources;
        ImWchar EllipsisChar;
        ImWchar FallbackChar;
        ImU8[(0x10FFFF+1)/8192/8] Used8kPagesMap;
        bool EllipsisAutoBake;
        ImGuiStorage RemapPairs;
    }

    struct ImVec4 {
        float x;
        float y;
        float z;
        float w;
    }

    struct stbrp_context_opaque {
        char[80] data;
    }

    struct ImGuiDockContext {
        ImGuiStorage Nodes;
        ImVector!(ImGuiDockRequest) Requests;
        ImVector!(ImGuiDockNodeSettings) NodesSettings;
        bool WantFullRebuild;
    }

    struct ImGuiSettingsHandler {
        const(char)* TypeName;
        ImGuiID TypeHash;
        void function(ImGuiContext* ctx,ImGuiSettingsHandler* handler) ClearAllFn;
        void function(ImGuiContext* ctx,ImGuiSettingsHandler* handler) ReadInitFn;
        void* function(ImGuiContext* ctx,ImGuiSettingsHandler* handler,const(char)* name) ReadOpenFn;
        void function(ImGuiContext* ctx,ImGuiSettingsHandler* handler,void* entry,const(char)* line) ReadLineFn;
        void function(ImGuiContext* ctx,ImGuiSettingsHandler* handler) ApplyAllFn;
        void function(ImGuiContext* ctx,ImGuiSettingsHandler* handler,ImGuiTextBuffer* out_buf) WriteAllFn;
        void* UserData;
    }

    struct ImDrawListSplitter {
        int _Current;
        int _Count;
        ImVector!(ImDrawChannel) _Channels;
    }

    struct ImGuiStoragePair {
        ImGuiID key;
        union { int val_i; float val_f; void* val_p;} ;
    }

    struct ImDrawChannel {
        ImVector!(ImDrawCmd) _CmdBuffer;
        ImVector!(ImDrawIdx) _IdxBuffer;
    }

    struct ImGuiTableColumnSettings {
        float WidthOrWeight;
        ImGuiID ID;
        ImGuiTableColumnIdx Index;
        ImGuiTableColumnIdx DisplayOrder;
        ImGuiTableColumnIdx SortOrder;
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImU8 SortDirection : 2;
        ImU8 bitfield_0;
        @property ImU8 SortDirection() { return GetValue!ImU8(bitfield_0, 0, 2); }
        @property void SortDirection(ImU8 aValue) { bitfield_0 = SetValue(bitfield_0, 0, 2, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 2.sizeof);
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImS8 IsEnabled : 2;
        ImS8 bitfield_1;
        @property ImS8 IsEnabled() { return GetValue!ImS8(bitfield_1, 0, 2); }
        @property void IsEnabled(ImS8 aValue) { bitfield_1 = SetValue(bitfield_1, 0, 2, aValue); };
        static assert((bitfield_1.sizeof * 8) >= 2.sizeof);
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImU8 IsStretch : 1;
        ImU8 bitfield_2;
        @property ImU8 IsStretch() { return GetValue!ImU8(bitfield_2, 0, 1); }
        @property void IsStretch(ImU8 aValue) { bitfield_2 = SetValue(bitfield_2, 0, 1, aValue); };
        static assert((bitfield_2.sizeof * 8) >= 1.sizeof);
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //bool IsLoaded : 1;
        bool bitfield_3;
        @property bool IsLoaded() { return GetValue!bool(bitfield_3, 0, 1); }
        @property void IsLoaded(bool aValue) { bitfield_3 = SetValue(bitfield_3, 0, 1, aValue); };
        static assert((bitfield_3.sizeof * 8) >= 1.sizeof);
    }

    struct ImGuiTextBuffer {
        ImVector!(char) Buf;
    }

    struct ImGuiListClipper {
        int DisplayStart;
        int DisplayEnd;
        int UserIndex;
        int ItemsCount;
        float ItemsHeight;
        ImGuiListClipperFlags Flags;
        double StartPosY;
        double StartSeekOffsetY;
        ImGuiContext* Ctx;
        void* TempData;
    }

    struct ImGuiInputEventMouseButton {
        int Button;
        bool Down;
        ImGuiMouseSource MouseSource;
    }

    struct ImGuiNextWindowData {
        ImGuiNextWindowDataFlags HasFlags;
        ImGuiCond PosCond;
        ImGuiCond SizeCond;
        ImGuiCond CollapsedCond;
        ImGuiCond DockCond;
        ImVec2 PosVal;
        ImVec2 PosPivotVal;
        ImVec2 SizeVal;
        ImVec2 ContentSizeVal;
        ImVec2 ScrollVal;
        ImGuiWindowFlags WindowFlags;
        ImGuiChildFlags ChildFlags;
        bool PosUndock;
        bool CollapsedVal;
        ImRect SizeConstraintRect;
        ImGuiSizeCallback SizeCallback;
        void* SizeCallbackUserData;
        float BgAlphaVal;
        ImGuiID ViewportId;
        ImGuiID DockId;
        ImGuiWindowClass WindowClass;
        ImVec2 MenuBarOffsetMinVal;
        ImGuiWindowRefreshFlags RefreshFlagsVal;
    }

    struct ImGuiPlatformMonitor {
        ImVec2 MainPos;
        ImVec2 MainSize;
        ImVec2 WorkPos;
        ImVec2 WorkSize;
        float DpiScale;
        void* PlatformHandle;
    }

    struct ImGuiMetricsConfig {
        bool ShowDebugLog;
        bool ShowIDStackTool;
        bool ShowWindowsRects;
        bool ShowWindowsBeginOrder;
        bool ShowTablesRects;
        bool ShowDrawCmdMesh;
        bool ShowDrawCmdBoundingBoxes;
        bool ShowTextEncodingViewer;
        bool ShowTextureUsedRect;
        bool ShowDockingNodes;
        int ShowWindowsRectsType;
        int ShowTablesRectsType;
        int HighlightMonitorIdx;
        ImGuiID HighlightViewportID;
        int SettingsDiscardMonths;
        bool SettingsHighlightOldEntries;
        bool ShowFontPreview;
    }

    struct ImGuiKeyOwnerData {
        ImGuiID OwnerCurr;
        ImGuiID OwnerNext;
        bool LockThisFrame;
        bool LockUntilRelease;
    }

    struct ImGuiPackedDate {
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImU16 Year : 7;
        //ImU16 Month : 4;
        //ImU16 Day : 5;
        ImU16 bitfield_0;
        @property ImU16 Year() { return GetValue!ImU16(bitfield_0, 0, 7); }
        @property void Year(ImU16 aValue) { bitfield_0 = SetValue(bitfield_0, 0, 7, aValue); };
        @property ImU16 Month() { return GetValue!ImU16(bitfield_0, 7, 4); }
        @property void Month(ImU16 aValue) { bitfield_0 = SetValue(bitfield_0, 7, 4, aValue); };
        @property ImU16 Day() { return GetValue!ImU16(bitfield_0, 11, 5); }
        @property void Day(ImU16 aValue) { bitfield_0 = SetValue(bitfield_0, 11, 5, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 16.sizeof);
    }

    struct ImGuiStyleMod {
        ImGuiStyleVar VarIdx;
        union { int[2] BackupInt; float[2] BackupFloat;} ;
    }

    struct ImGuiSelectionBasicStorage {
        int Size;
        bool PreserveOrder;
        void* UserData;
        ImGuiID function(ImGuiSelectionBasicStorage* self,int idx) AdapterIndexToStorageId;
        int _SelectionOrder;
        ImGuiStorage _Storage;
    }

    struct ImGuiViewport {
        ImGuiID ID;
        ImGuiViewportFlags Flags;
        ImVec2 Pos;
        ImVec2 Size;
        ImVec2 FramebufferScale;
        ImVec2 WorkPos;
        ImVec2 WorkSize;
        float DpiScale;
        ImGuiID ParentViewportId;
        ImGuiViewport* ParentViewport;
        ImDrawData* DrawData;
        void* RendererUserData;
        void* PlatformUserData;
        void* PlatformIconData;
        void* PlatformHandle;
        void* PlatformHandleRaw;
        bool PlatformWindowCreated;
        bool PlatformRequestMove;
        bool PlatformRequestResize;
        bool PlatformRequestClose;
    }

    struct ImGuiWindowClass {
        ImGuiID ClassId;
        ImGuiID ParentViewportId;
        ImGuiID FocusRouteParentWindowId;
        ImGuiViewportFlags ViewportFlagsOverrideSet;
        ImGuiViewportFlags ViewportFlagsOverrideClear;
        ImGuiTabItemFlags TabItemFlagsOverrideSet;
        ImGuiDockNodeFlags DockNodeFlagsOverrideSet;
        bool DockingAlwaysTabBar;
        bool DockingAllowUnclassed;
        void* PlatformIconData;
    }

    struct ImGuiTableSettings {
        ImGuiID ID;
        ImGuiTableFlags SaveFlags;
        float RefScale;
        ImGuiTableColumnIdx ColumnsCount;
        ImGuiTableColumnIdx ColumnsCountMax;
        ImGuiPackedDate LastUsedDate;
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //bool WantApply : 1;
        bool bitfield_0;
        @property bool WantApply() { return GetValue!bool(bitfield_0, 0, 1); }
        @property void WantApply(bool aValue) { bitfield_0 = SetValue(bitfield_0, 0, 1, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 1.sizeof);
    }

    struct ImVec2i {
        int x;
        int y;
    }

    struct ImGuiSettingsCleanupArgs {
        ImGuiID TypeHashFilter;
        int DiscardOlderThanMonths;
        bool DiscardWhenMissingDate;
        bool DiscardAll;
        bool SetCurrentSessionDateToAll;
        bool SetCurrentSessionDateWhenMissingDate;
        int _DiscardOlderThanDate;
    }

    struct ImFontAtlas {
        ImFontAtlasFlags Flags;
        ImTextureFormat TexDesiredFormat;
        int TexGlyphPadding;
        int TexMinWidth;
        int TexMinHeight;
        int TexMaxWidth;
        int TexMaxHeight;
        void* UserData;
        ImTextureRef TexRef;
        ImTextureData* TexData;
        ImVector!(ImTextureData*) TexList;
        bool Locked;
        bool RendererHasTextures;
        bool TexIsBuilt;
        bool TexPixelsUseColors;
        ImVec2 TexUvScale;
        ImVec2 TexUvWhitePixel;
        ImVector!(ImFont*) Fonts;
        ImVector!(ImFontConfig) Sources;
        ImVec4[(32)+1] TexUvLines;
        int TexNextUniqueID;
        int FontNextUniqueID;
        ImVector!(ImDrawListSharedData*) DrawListSharedDatas;
        ImFontAtlasBuilder* Builder;
        const(ImFontLoader)* FontLoader;
        const(char)* FontLoaderName;
        void* FontLoaderData;
        uint FontLoaderFlags;
        int RefCount;
        ImGuiContext* OwnerContext;
    }

    struct ImGuiTreeNodeStackData {
        ImGuiID ID;
        ImGuiTreeNodeFlags TreeFlags;
        ImGuiItemFlags ItemFlags;
        ImRect NavRect;
        float DrawLinesX1;
        float DrawLinesToNodesY2;
        ImGuiTableColumnIdx DrawLinesTableColumn;
    }

    struct ImGuiTableHeaderData {
        ImGuiTableColumnIdx Index;
        ImU32 TextColor;
        ImU32 BgColor0;
        ImU32 BgColor1;
    }

    struct ImGuiFocusScopeData {
        ImGuiID ID;
        ImGuiID WindowID;
    }

    struct ImGuiListClipperData {
        ImGuiListClipper* ListClipper;
        float LossynessOffset;
        int StepNo;
        int ItemsFrozen;
        ImVector!(ImGuiListClipperRange) Ranges;
    }

    struct ImGuiViewportP {
        ImGuiViewport _ImGuiViewport;
        ImGuiWindow* Window;
        int Idx;
        int LastFrameActive;
        int LastFocusedStampCount;
        ImGuiID LastNameHash;
        ImVec2 LastPos;
        ImVec2 LastSize;
        float Alpha;
        float LastAlpha;
        bool LastFocusedHadNavWindow;
        short PlatformMonitor;
        float[2] BgFgDrawListsLastTimeActive;
        ImDrawList*[2] BgFgDrawLists;
        ImDrawData DrawDataP;
        ImDrawDataBuilder DrawDataBuilder;
        ImVec2 LastPlatformPos;
        ImVec2 LastPlatformSize;
        ImVec2 LastRendererSize;
        ImVec2 WorkInsetMin;
        ImVec2 WorkInsetMax;
        ImVec2 BuildWorkInsetMin;
        ImVec2 BuildWorkInsetMax;
    }

    struct ImVec1 {
        float x;
    }

    struct ImGuiNavItemData {
        ImGuiWindow* Window;
        ImGuiID ID;
        ImGuiID FocusScopeId;
        ImRect RectRel;
        ImGuiItemFlags ItemFlags;
        float DistBox;
        float DistCenter;
        float DistAxial;
        ImGuiSelectionUserData SelectionUserData;
    }

    struct ImGuiSelectionRequest {
        ImGuiSelectionRequestType Type;
        bool Selected;
        ImS8 RangeDirection;
        ImGuiSelectionUserData RangeFirstItem;
        ImGuiSelectionUserData RangeLastItem;
    }

    struct ImFontBaked {
        ImVector!(float) IndexAdvanceX;
        float FallbackAdvanceX;
        float Size;
        float RasterizerDensity;
        ImVector!(ImU16) IndexLookup;
        ImVector!(ImFontGlyph) Glyphs;
        int FallbackGlyphIndex;
        float Ascent;
        float Descent;
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //uint MetricsTotalSurface : 26;
        //uint WantDestroy : 1;
        //uint LoadNoFallback : 1;
        //uint LoadNoRenderOnLayout : 1;
        uint bitfield_0;
        @property uint MetricsTotalSurface() { return GetValue!uint(bitfield_0, 0, 26); }
        @property void MetricsTotalSurface(uint aValue) { bitfield_0 = SetValue(bitfield_0, 0, 26, aValue); };
        @property uint WantDestroy() { return GetValue!uint(bitfield_0, 26, 1); }
        @property void WantDestroy(uint aValue) { bitfield_0 = SetValue(bitfield_0, 26, 1, aValue); };
        @property uint LoadNoFallback() { return GetValue!uint(bitfield_0, 27, 1); }
        @property void LoadNoFallback(uint aValue) { bitfield_0 = SetValue(bitfield_0, 27, 1, aValue); };
        @property uint LoadNoRenderOnLayout() { return GetValue!uint(bitfield_0, 28, 1); }
        @property void LoadNoRenderOnLayout(uint aValue) { bitfield_0 = SetValue(bitfield_0, 28, 1, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 29.sizeof);
        int LastUsedFrame;
        ImGuiID BakedId;
        ImFont* OwnerFont;
        void* FontLoaderDatas;
    }

    struct ImFontLoader {
        const(char)* Name;
        bool function(ImFontAtlas* atlas) LoaderInit;
        void function(ImFontAtlas* atlas) LoaderShutdown;
        bool function(ImFontAtlas* atlas,ImFontConfig* src) FontSrcInit;
        void function(ImFontAtlas* atlas,ImFontConfig* src) FontSrcDestroy;
        bool function(ImFontAtlas* atlas,ImFontConfig* src,ImWchar codepoint) FontSrcContainsGlyph;
        bool function(ImFontAtlas* atlas,ImFontConfig* src,ImFontBaked* baked,void* loader_data_for_baked_src) FontBakedInit;
        void function(ImFontAtlas* atlas,ImFontConfig* src,ImFontBaked* baked,void* loader_data_for_baked_src) FontBakedDestroy;
        bool function(ImFontAtlas* atlas,ImFontConfig* src,ImFontBaked* baked,void* loader_data_for_baked_src,ImWchar codepoint,ImFontGlyph* out_glyph,float* out_advance_x) FontBakedLoadGlyph;
        size_t FontBakedSrcLoaderDataSize;
    }

    struct StbUndoState {
        StbUndoRecord[99] undo_rec;
        char[999] undo_char;
        short undo_point;
        short redo_point;
        int undo_char_point;
        int redo_char_point;
    }

    struct ImGuiComboPreviewData {
        ImRect PreviewRect;
        ImVec2 BackupCursorPos;
        ImVec2 BackupCursorMaxPos;
        ImVec2 BackupCursorPosPrevLine;
        float BackupPrevLineTextBaseOffset;
        ImGuiLayoutType BackupLayout;
    }

    struct ImVec2ih {
        short x;
        short y;
    }

    struct ImGuiSizeCallbackData {
        void* UserData;
        ImVec2 Pos;
        ImVec2 CurrentSize;
        ImVec2 DesiredSize;
    }

    struct ImGuiShrinkWidthItem {
        int Index;
        float Width;
        float InitialWidth;
    }

    struct ImRect {
        ImVec2 Min;
        ImVec2 Max;
    }

    struct ImGuiMultiSelectIO {
        ImVector!(ImGuiSelectionRequest) Requests;
        ImGuiSelectionUserData RangeSrcItem;
        ImGuiSelectionUserData NavIdItem;
        bool NavIdSelected;
        bool RangeSrcReset;
        int ItemsCount;
    }

    struct ImGuiIO {
        ImGuiConfigFlags ConfigFlags;
        ImGuiBackendFlags BackendFlags;
        ImVec2 DisplaySize;
        ImVec2 DisplayFramebufferScale;
        float DeltaTime;
        float IniSavingRate;
        const(char)* IniFilename;
        const(char)* LogFilename;
        void* UserData;
        ImFontAtlas* Fonts;
        ImFont* FontDefault;
        bool FontAllowUserScaling;
        bool ConfigNavSwapGamepadButtons;
        bool ConfigNavMoveSetMousePos;
        bool ConfigNavCaptureKeyboard;
        bool ConfigNavEscapeClearFocusItem;
        bool ConfigNavEscapeClearFocusWindow;
        bool ConfigNavCursorVisibleAuto;
        bool ConfigNavCursorVisibleAlways;
        bool ConfigDockingNoSplit;
        bool ConfigDockingNoDockingOver;
        bool ConfigDockingWithShift;
        bool ConfigDockingAlwaysTabBar;
        bool ConfigDockingTransparentPayload;
        bool ConfigViewportsNoAutoMerge;
        bool ConfigViewportsNoTaskBarIcon;
        bool ConfigViewportsNoDecoration;
        bool ConfigViewportsNoDefaultParent;
        bool ConfigViewportsPlatformFocusSetsImGuiFocus;
        bool ConfigDpiScaleFonts;
        bool ConfigDpiScaleViewports;
        bool ConfigMacOSXBehaviors;
        bool ConfigInputTrickleEventQueue;
        bool ConfigInputTextCursorBlink;
        bool ConfigInputTextEnterKeepActive;
        ImGuiColorEditFlags ConfigColorEditFlags;
        bool ConfigDragClickToInputText;
        bool ConfigWindowsResizeFromEdges;
        bool ConfigWindowsMoveFromTitleBarOnly;
        bool ConfigWindowsCopyContentsWithCtrlC;
        bool ConfigScrollbarScrollByPage;
        bool ConfigIniSettingsSaveLastUsedDate;
        int ConfigIniSettingsAutoDiscardMonths;
        bool ConfigDebugIniSettings;
        bool MouseDrawCursor;
        float ConfigMemoryCompactTimer;
        float MouseDoubleClickTime;
        float MouseDoubleClickMaxDist;
        float MouseSingleClickDelay;
        float MouseDragThreshold;
        float KeyRepeatDelay;
        float KeyRepeatRate;
        bool ConfigErrorRecovery;
        bool ConfigErrorRecoveryEnableAssert;
        bool ConfigErrorRecoveryEnableDebugLog;
        bool ConfigErrorRecoveryEnableTooltip;
        bool ConfigDebugIsDebuggerPresent;
        bool ConfigDebugHighlightIdConflicts;
        bool ConfigDebugHighlightIdConflictsShowItemPicker;
        bool ConfigDebugBeginReturnValueOnce;
        bool ConfigDebugBeginReturnValueLoop;
        bool ConfigDebugIgnoreFocusLoss;
        const(char)* BackendPlatformName;
        const(char)* BackendRendererName;
        void* BackendPlatformUserData;
        void* BackendRendererUserData;
        void* BackendLanguageUserData;
        bool WantCaptureMouse;
        bool WantCaptureKeyboard;
        bool WantTextInput;
        bool WantSetMousePos;
        bool WantSaveIniSettings;
        bool NavActive;
        bool NavVisible;
        float Framerate;
        int MetricsRenderVertices;
        int MetricsRenderIndices;
        int MetricsRenderWindows;
        int MetricsActiveWindows;
        ImVec2 MouseDelta;
        ImGuiContext* Ctx;
        ImVec2 MousePos;
        bool[5] MouseDown;
        float MouseWheel;
        float MouseWheelH;
        ImGuiMouseSource MouseSource;
        ImGuiID MouseHoveredViewport;
        bool KeyCtrl;
        bool KeyShift;
        bool KeyAlt;
        bool KeySuper;
        ImGuiKeyChord KeyMods;
        ImGuiKeyData[ImGuiKey.NamedKey_COUNT] KeysData;
        bool WantCaptureMouseUnlessPopupClose;
        ImVec2 MousePosPrev;
        ImVec2[5] MouseClickedPos;
        double[5] MouseClickedTime;
        bool[5] MouseClicked;
        bool[5] MouseDoubleClicked;
        ImU16[5] MouseClickedCount;
        ImU16[5] MouseClickedLastCount;
        bool[5] MouseReleased;
        double[5] MouseReleasedTime;
        bool[5] MouseDownOwned;
        bool[5] MouseDownOwnedUnlessPopupClose;
        bool MouseWheelRequestAxisSwap;
        bool MouseCtrlLeftAsRightClick;
        float[5] MouseDownDuration;
        float[5] MouseDownDurationPrev;
        ImVec2[5] MouseDragMaxDistanceAbs;
        float[5] MouseDragMaxDistanceSqr;
        float PenPressure;
        bool AppFocusLost;
        bool AppAcceptingEvents;
        ImWchar16 InputQueueSurrogate;
        ImVector!(ImWchar) InputQueueCharacters;
    }

    struct ImGuiTableInstanceData {
        ImGuiID TableInstanceID;
        float LastOuterHeight;
        float LastTopHeadersRowHeight;
        float LastFrozenHeight;
        int HoveredRowLast;
        int HoveredRowNext;
    }

    struct ImTextureRef {
        ImTextureData* _TexData;
        ImTextureID _TexID;
    }

    struct ImGuiPayload {
        void* Data;
        int DataSize;
        ImGuiID SourceId;
        ImGuiID SourceParentId;
        int DataFrameCount;
        char[32+1] DataType;
        bool Preview;
        bool Delivery;
    }

    struct ImBitVector {
        ImVector!(ImU32) Storage;
    }

    struct ImGuiInputEventKey {
        ImGuiKey Key;
        bool Down;
        float AnalogValue;
    }

    struct ImGuiColorMod {
        ImGuiCol Col;
        ImVec4 BackupValue;
    }

    struct ImGuiInputTextCallbackData {
        ImGuiContext* Ctx;
        ImGuiInputTextFlags EventFlag;
        ImGuiInputTextFlags Flags;
        void* UserData;
        ImGuiID ID;
        ImGuiKey EventKey;
        ImWchar EventChar;
        bool EventActivated;
        bool BufDirty;
        char* Buf;
        int BufTextLen;
        int BufSize;
        int CursorPos;
        int SelectionStart;
        int SelectionEnd;
    }

    struct ImGuiInputEventAppFocused {
        bool Focused;
    }

    struct ImGuiTableCellData {
        ImU32 BgColor;
        ImGuiTableColumnIdx Column;
    }

    struct ImFontConfig {
        char[40] Name;
        void* FontData;
        int FontDataSize;
        bool FontDataOwnedByAtlas;
        bool MergeMode;
        bool PixelSnapH;
        ImS8 OversampleH;
        ImS8 OversampleV;
        ImWchar EllipsisChar;
        float SizePixels;
        const(ImWchar)* GlyphRanges;
        const(ImWchar)* GlyphExcludeRanges;
        ImVec2 GlyphOffset;
        float GlyphMinAdvanceX;
        float GlyphMaxAdvanceX;
        float GlyphExtraAdvanceX;
        ImU32 FontNo;
        uint FontLoaderFlags;
        float RasterizerMultiply;
        float RasterizerDensity;
        float ExtraSizeScale;
        ImFontFlags Flags;
        ImFont* DstFont;
        const(ImFontLoader)* FontLoader;
        void* FontLoaderData;
    }

    struct ImGuiLastItemData {
        ImGuiID ID;
        ImGuiItemFlags ItemFlags;
        ImGuiItemStatusFlags StatusFlags;
        ImRect Rect;
        ImRect NavRect;
        ImRect DisplayRect;
        ImRect ClipRect;
        ImGuiKeyChord Shortcut;
    }

    struct ImDrawCmdHeader {
        ImVec4 ClipRect;
        ImTextureRef TexRef;
        uint VtxOffset;
    }

    struct ImDrawListSharedData {
        ImVec2 TexUvWhitePixel;
        const(ImVec4)* TexUvLines;
        ImFontAtlas* FontAtlas;
        ImFont* Font;
        float FontSize;
        float FontScale;
        float CurveTessellationTol;
        float CircleTessellationMaxError;
        float InitialFringeScale;
        ImDrawListFlags InitialFlags;
        ImVec4 ClipRectFullscreen;
        ImVector!(ImVec2) TempBuffer;
        ImVector!(ImDrawList*) DrawLists;
        ImGuiContext* Context;
        ImVec2[48] ArcFastVtx;
        float ArcFastRadiusCutoff;
        ImU8[64] CircleSegmentCounts;
    }

    struct ImGuiDebugAllocInfo {
        int TotalAllocCount;
        int TotalFreeCount;
        ImS16 LastEntriesIdx;
        ImGuiDebugAllocEntry[6] LastEntriesBuf;
    }

    struct ImDrawData {
        bool Valid;
        int FrameCount;
        int TotalIdxCount;
        int TotalVtxCount;
        ImVector!(ImDrawList*) CmdLists;
        ImVec2 DisplayPos;
        ImVec2 DisplaySize;
        ImVec2 FramebufferScale;
        ImGuiViewport* OwnerViewport;
        ImVector!(ImTextureData*)* Textures;
    }

    struct ImGuiInputTextState {
        ImGuiContext* Ctx;
        ImStbTexteditState* Stb;
        ImGuiInputTextFlags Flags;
        ImGuiID ID;
        int TextLen;
        const(char)* TextSrc;
        ImVector!(char) TextA;
        ImVector!(char) TextToRevertTo;
        ImVector!(char) CallbackTextBackup;
        int BufCapacity;
        ImVec2 Scroll;
        int LineCount;
        float WrapWidth;
        float CursorAnim;
        bool CursorFollow;
        bool CursorCenterY;
        bool SelectedAllMouseLock;
        bool EditedBefore;
        bool EditedThisFrame;
        bool WantReloadUserBuf;
        ImS8 LastMoveDirectionLR;
        int ReloadSelectionStart;
        int ReloadSelectionEnd;
    }

    struct ImGuiLocEntry {
        ImGuiLocKey Key;
        const(char)* Text;
    }

    struct ImGuiPtrOrIndex {
        void* Ptr;
        int Index;
    }

    struct ImGuiDataTypeStorage {
        ImU8[8] Data;
    }

    struct STB_TexteditState {
        int cursor;
        int select_start;
        int select_end;
        char insert_mode;
        int row_count_per_page;
        char cursor_at_end_of_line;
        char initialized;
        char has_preferred_x;
        char single_line;
        char padding1;
        char padding2;
        char padding3;
        float preferred_x;
        StbUndoState undostate;
    }

    struct ImGuiInputTextDeactivatedState {
        ImGuiID ID;
        int ElapseFrame;
        ImVector!(char) TextA;
    }

    struct ImTextureRect {
        ushort x;
        ushort y;
        ushort w;
        ushort h;
    }

    struct ImDrawCmd {
        ImVec4 ClipRect;
        ImTextureRef TexRef;
        uint VtxOffset;
        uint IdxOffset;
        uint ElemCount;
        ImDrawCallback UserCallback;
        void* UserCallbackData;
        int UserCallbackDataSize;
        int UserCallbackDataOffset;
    }

    struct ImGuiContextHook {
        ImGuiID HookId;
        ImGuiContextHookType Type;
        ImGuiID Owner;
        ImGuiContextHookCallback Callback;
        void* UserData;
    }

    struct ImGuiIDStackTool {
        bool OptHexEncodeNonAsciiChars;
        bool OptCopyToClipboardOnCtrlC;
        int LastActiveFrame;
        float CopyToClipboardLastTime;
    }

    struct ImGuiTextIndex {
        ImVector!(int) Offsets;
        int EndOffset;
    }

    struct ImFontStackData {
        ImFont* Font;
        float FontSizeBeforeScaling;
        float FontSizeAfterScaling;
    }

    struct ImGuiBoxSelectState {
        ImGuiID ID;
        bool IsActive;
        bool IsStarting;
        bool IsStartedFromVoid;
        bool IsStartedSetNavIdOnce;
        bool RequestClear;
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImGuiKeyChord KeyMods : 16;
        ImGuiKeyChord bitfield_0;
        @property ImGuiKeyChord KeyMods() { return GetValue!ImGuiKeyChord(bitfield_0, 0, 16); }
        @property void KeyMods(ImGuiKeyChord aValue) { bitfield_0 = SetValue(bitfield_0, 0, 16, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 16.sizeof);
        ImVec2 StartPosRel;
        ImVec2 EndPosRel;
        ImVec2 ScrollAccum;
        ImGuiWindow* Window;
        bool UnclipMode;
        ImRect UnclipRect;
        ImRect[2] UnclipRects;
        ImRect BoxSelectRectPrev;
        ImRect BoxSelectRectCurr;
    }

    struct ImGuiDockNode {
        ImGuiID ID;
        ImGuiDockNodeFlags SharedFlags;
        ImGuiDockNodeFlags LocalFlags;
        ImGuiDockNodeFlags LocalFlagsInWindows;
        ImGuiDockNodeFlags MergedFlags;
        ImGuiDockNodeState State;
        ImGuiDockNode* ParentNode;
        ImGuiDockNode*[2] ChildNodes;
        ImVector!(ImGuiWindow*) Windows;
        ImGuiTabBar* TabBar;
        ImVec2 Pos;
        ImVec2 Size;
        ImVec2 SizeRef;
        ImGuiAxis SplitAxis;
        ImU32 LastBgColor;
        ImGuiWindowClass WindowClass;
        ImGuiWindow* HostWindow;
        ImGuiWindow* VisibleWindow;
        ImGuiDockNode* CentralNode;
        ImGuiDockNode* OnlyNodeWithWindows;
        int CountNodeWithWindows;
        int LastFrameAlive;
        int LastFrameActive;
        int LastFrameFocused;
        ImGuiID LastFocusedNodeId;
        ImGuiID SelectedTabId;
        ImGuiID WantCloseTabId;
        ImGuiID RefViewportId;
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImU8 AuthorityForPos : 3;
        //ImU8 AuthorityForSize : 3;
        //ImU8 AuthorityForViewport : 3;
        ImU8 bitfield_0;
        @property ImU8 AuthorityForPos() { return GetValue!ImU8(bitfield_0, 0, 3); }
        @property void AuthorityForPos(ImU8 aValue) { bitfield_0 = SetValue(bitfield_0, 0, 3, aValue); };
        @property ImU8 AuthorityForSize() { return GetValue!ImU8(bitfield_0, 3, 3); }
        @property void AuthorityForSize(ImU8 aValue) { bitfield_0 = SetValue(bitfield_0, 3, 3, aValue); };
        @property ImU8 AuthorityForViewport() { return GetValue!ImU8(bitfield_0, 6, 3); }
        @property void AuthorityForViewport(ImU8 aValue) { bitfield_0 = SetValue(bitfield_0, 6, 3, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 9.sizeof);
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //bool IsVisible : 1;
        //bool IsFocused : 1;
        //bool IsBgDrawnThisFrame : 1;
        //bool HasCloseButton : 1;
        //bool HasWindowMenuButton : 1;
        //bool HasCentralNodeChild : 1;
        //bool WantCloseAll : 1;
        //bool WantLockSizeOnce : 1;
        //bool WantMouseMove : 1;
        //bool WantHiddenTabBarUpdate : 1;
        //bool WantHiddenTabBarToggle : 1;
        bool bitfield_1;
        @property bool IsVisible() { return GetValue!bool(bitfield_1, 0, 1); }
        @property void IsVisible(bool aValue) { bitfield_1 = SetValue(bitfield_1, 0, 1, aValue); };
        @property bool IsFocused() { return GetValue!bool(bitfield_1, 1, 1); }
        @property void IsFocused(bool aValue) { bitfield_1 = SetValue(bitfield_1, 1, 1, aValue); };
        @property bool IsBgDrawnThisFrame() { return GetValue!bool(bitfield_1, 2, 1); }
        @property void IsBgDrawnThisFrame(bool aValue) { bitfield_1 = SetValue(bitfield_1, 2, 1, aValue); };
        @property bool HasCloseButton() { return GetValue!bool(bitfield_1, 3, 1); }
        @property void HasCloseButton(bool aValue) { bitfield_1 = SetValue(bitfield_1, 3, 1, aValue); };
        @property bool HasWindowMenuButton() { return GetValue!bool(bitfield_1, 4, 1); }
        @property void HasWindowMenuButton(bool aValue) { bitfield_1 = SetValue(bitfield_1, 4, 1, aValue); };
        @property bool HasCentralNodeChild() { return GetValue!bool(bitfield_1, 5, 1); }
        @property void HasCentralNodeChild(bool aValue) { bitfield_1 = SetValue(bitfield_1, 5, 1, aValue); };
        @property bool WantCloseAll() { return GetValue!bool(bitfield_1, 6, 1); }
        @property void WantCloseAll(bool aValue) { bitfield_1 = SetValue(bitfield_1, 6, 1, aValue); };
        @property bool WantLockSizeOnce() { return GetValue!bool(bitfield_1, 7, 1); }
        @property void WantLockSizeOnce(bool aValue) { bitfield_1 = SetValue(bitfield_1, 7, 1, aValue); };
        @property bool WantMouseMove() { return GetValue!bool(bitfield_1, 8, 1); }
        @property void WantMouseMove(bool aValue) { bitfield_1 = SetValue(bitfield_1, 8, 1, aValue); };
        @property bool WantHiddenTabBarUpdate() { return GetValue!bool(bitfield_1, 9, 1); }
        @property void WantHiddenTabBarUpdate(bool aValue) { bitfield_1 = SetValue(bitfield_1, 9, 1, aValue); };
        @property bool WantHiddenTabBarToggle() { return GetValue!bool(bitfield_1, 10, 1); }
        @property void WantHiddenTabBarToggle(bool aValue) { bitfield_1 = SetValue(bitfield_1, 10, 1, aValue); };
        static assert((bitfield_1.sizeof * 8) >= 11.sizeof);
    }

    struct ImGuiStorage {
        ImVector!(ImGuiStoragePair) Data;
    }

    struct ImFontGlyphRangesBuilder {
        ImVector!(ImU32) UsedChars;
    }

    struct ImGuiTextFilter {
        char[256] InputBuf;
        ImVector!(ImGuiTextRange) Filters;
        int CountGrep;
    }

    struct ImGuiTabBar {
        ImGuiWindow* Window;
        ImVector!(ImGuiTabItem) Tabs;
        ImGuiTabBarFlags Flags;
        ImGuiID ID;
        ImGuiID SelectedTabId;
        ImGuiID NextSelectedTabId;
        ImGuiID NextScrollToTabId;
        ImGuiID VisibleTabId;
        int CurrFrameVisible;
        int PrevFrameVisible;
        ImRect BarRect;
        float BarRectPrevWidth;
        float CurrTabsContentsHeight;
        float PrevTabsContentsHeight;
        float WidthAllTabs;
        float WidthAllTabsIdeal;
        float ScrollingAnim;
        float ScrollingTarget;
        float ScrollingTargetDistToVisibility;
        float ScrollingSpeed;
        float ScrollingRectMinX;
        float ScrollingRectMaxX;
        float SeparatorMinX;
        float SeparatorMaxX;
        ImGuiID ReorderRequestTabId;
        ImS16 ReorderRequestOffset;
        ImS8 BeginCount;
        bool WantLayout;
        bool VisibleTabWasSubmitted;
        bool TabsAddedNew;
        bool ScrollButtonEnabled;
        ImS16 TabsActiveCount;
        ImS16 LastTabItemIdx;
        float ItemSpacingY;
        ImVec2 FramePadding;
        ImVec2 BackupCursorPos;
        ImGuiTextBuffer TabsNames;
    }

    struct ImGuiInputEvent {
        ImGuiInputEventType Type;
        ImGuiInputSource Source;
        ImU32 EventId;
        union { ImGuiInputEventMousePos MousePos; ImGuiInputEventMouseWheel MouseWheel; ImGuiInputEventMouseButton MouseButton; ImGuiInputEventMouseViewport MouseViewport; ImGuiInputEventKey Key; ImGuiInputEventText Text; ImGuiInputEventAppFocused AppFocused;} ;
        bool AddedByTestEngine;
    }

    struct ImVec2 {
        float x;
        float y;
    }

    struct ImGuiDeactivatedItemData {
        ImGuiID ID;
        int ElapseFrame;
        bool HasBeenEditedBefore;
        bool IsAlive;
    }

    struct ImDrawVert {
        ImVec2 pos;
        ImVec2 uv;
        ImU32 col;
    }

    struct ImFontAtlasPostProcessData {
        ImFontAtlas* FontAtlas;
        ImFont* Font;
        ImFontConfig* FontSrc;
        ImFontBaked* FontBaked;
        ImFontGlyph* Glyph;
        void* Pixels;
        ImTextureFormat Format;
        int Pitch;
        int Width;
        int Height;
    }

    struct ImGuiGroupData {
        ImGuiID WindowID;
        ImVec2 BackupCursorPos;
        ImVec2 BackupCursorMaxPos;
        ImVec2 BackupCursorPosPrevLine;
        ImVec1 BackupIndent;
        ImVec1 BackupGroupOffset;
        ImVec2 BackupCurrLineSize;
        float BackupCurrLineTextBaseOffset;
        ImGuiID BackupActiveIdIsAlive;
        bool BackupAnyIdHasBeenEditedThisFrame;
        bool BackupDeactivatedIdIsAlive;
        bool BackupHoveredIdIsAlive;
        bool BackupIsSameLine;
        bool EmitItem;
    }

    struct ImGuiPlatformIO {
        const(char)* function(ImGuiContext* ctx) Platform_GetClipboardTextFn;
        void function(ImGuiContext* ctx,const(char)* text) Platform_SetClipboardTextFn;
        void* Platform_ClipboardUserData;
        bool function(ImGuiContext* ctx,const(char)* path) Platform_OpenInShellFn;
        void* Platform_OpenInShellUserData;
        void function(ImGuiContext* ctx,ImGuiViewport* viewport,ImGuiPlatformImeData* data) Platform_SetImeDataFn;
        void* Platform_ImeUserData;
        ImWchar Platform_LocaleDecimalPoint;
        int Platform_SessionDate;
        int Renderer_TextureMaxWidth;
        int Renderer_TextureMaxHeight;
        void* Renderer_RenderState;
        ImDrawCallback DrawCallback_ResetRenderState;
        ImDrawCallback DrawCallback_SetSamplerLinear;
        ImDrawCallback DrawCallback_SetSamplerNearest;
        void function(ImGuiViewport* vp) Platform_CreateWindow;
        void function(ImGuiViewport* vp) Platform_DestroyWindow;
        void function(ImGuiViewport* vp) Platform_ShowWindow;
        void function(ImGuiViewport* vp,ImVec2 pos) Platform_SetWindowPos;
        ImVec2 function(ImGuiViewport* vp) Platform_GetWindowPos;
        void function(ImGuiViewport* vp,ImVec2 size) Platform_SetWindowSize;
        ImVec2 function(ImGuiViewport* vp) Platform_GetWindowSize;
        ImVec2 function(ImGuiViewport* vp) Platform_GetWindowFramebufferScale;
        void function(ImGuiViewport* vp) Platform_SetWindowFocus;
        bool function(ImGuiViewport* vp) Platform_GetWindowFocus;
        bool function(ImGuiViewport* vp) Platform_GetWindowMinimized;
        void function(ImGuiViewport* vp,const(char)* str) Platform_SetWindowTitle;
        void function(ImGuiViewport* vp,float alpha) Platform_SetWindowAlpha;
        void function(ImGuiViewport* vp) Platform_UpdateWindow;
        void function(ImGuiViewport* vp,void* render_arg) Platform_RenderWindow;
        void function(ImGuiViewport* vp,void* render_arg) Platform_SwapBuffers;
        float function(ImGuiViewport* vp) Platform_GetWindowDpiScale;
        void function(ImGuiViewport* vp) Platform_OnChangedViewport;
        ImVec4 function(ImGuiViewport* vp) Platform_GetWindowWorkAreaInsets;
        int function(ImGuiViewport* vp,ImU64 vk_inst,const void* vk_allocators,ImU64* out_vk_surface) Platform_CreateVkSurface;
        void function(ImGuiViewport* vp) Renderer_CreateWindow;
        void function(ImGuiViewport* vp) Renderer_DestroyWindow;
        void function(ImGuiViewport* vp,ImVec2 size) Renderer_SetWindowSize;
        void function(ImGuiViewport* vp,void* render_arg) Renderer_RenderWindow;
        void function(ImGuiViewport* vp,void* render_arg) Renderer_SwapBuffers;
        ImVector!(ImGuiPlatformMonitor) Monitors;
        ImVector!(ImTextureData*) Textures;
        ImVector!(ImGuiViewport*) Viewports;
    }

    struct ImColor {
        ImVec4 Value;
    }

    struct ImGuiOldColumns {
        ImGuiID ID;
        ImGuiOldColumnFlags Flags;
        bool IsFirstFrame;
        bool IsBeingResized;
        int Current;
        int Count;
        float OffMinX;
        float OffMaxX;
        float LineMinY;
        float LineMaxY;
        float HostCursorPosY;
        float HostCursorMaxPosX;
        ImRect HostInitialClipRect;
        ImRect HostBackupClipRect;
        ImRect HostBackupParentWorkRect;
        ImVector!(ImGuiOldColumnData) Columns;
        ImDrawListSplitter Splitter;
    }

    struct ImTextureData {
        int UniqueID;
        ImTextureStatus Status;
        void* BackendUserData;
        void* QueueUserData;
        ImTextureID TexID;
        ImTextureFormat Format;
        int Width;
        int Height;
        int BytesPerPixel;
        char* Pixels;
        ImTextureRect UsedRect;
        ImTextureRect UpdateRect;
        ImVector!(ImTextureRect) Updates;
        int UnusedFrames;
        ushort RefCount;
        bool UseColors;
        bool WantDestroyNextFrame;
    }

    struct ImGuiStyle {
        float FontSizeBase;
        float FontScaleMain;
        float FontScaleDpi;
        float Alpha;
        float DisabledAlpha;
        ImVec2 WindowPadding;
        float WindowRounding;
        float WindowBorderSize;
        float WindowBorderHoverPadding;
        ImVec2 WindowMinSize;
        ImVec2 WindowTitleAlign;
        ImGuiDir WindowMenuButtonPosition;
        float ChildRounding;
        float ChildBorderSize;
        float PopupRounding;
        float PopupBorderSize;
        ImVec2 FramePadding;
        float FrameRounding;
        float FrameBorderSize;
        ImVec2 ItemSpacing;
        ImVec2 ItemInnerSpacing;
        ImVec2 CellPadding;
        ImVec2 TouchExtraPadding;
        float IndentSpacing;
        float ColumnsMinSpacing;
        float ScrollbarSize;
        float ScrollbarRounding;
        float ScrollbarPadding;
        float GrabMinSize;
        float GrabRounding;
        float LogSliderDeadzone;
        float ImageRounding;
        float ImageBorderSize;
        float TabRounding;
        float TabBorderSize;
        float TabMinWidthBase;
        float TabMinWidthShrink;
        float TabCloseButtonMinWidthSelected;
        float TabCloseButtonMinWidthUnselected;
        float TabBarBorderSize;
        float TabBarOverlineSize;
        float TableAngledHeadersAngle;
        ImVec2 TableAngledHeadersTextAlign;
        ImGuiTreeNodeFlags TreeLinesFlags;
        float TreeLinesSize;
        float TreeLinesRounding;
        float MenuItemRounding;
        float SelectableRounding;
        float DragDropTargetRounding;
        float DragDropTargetBorderSize;
        float DragDropTargetPadding;
        float ColorMarkerSize;
        ImGuiDir ColorButtonPosition;
        ImVec2 ButtonTextAlign;
        ImVec2 SelectableTextAlign;
        float InputTextCursorSize;
        float SeparatorSize;
        float SeparatorTextBorderSize;
        ImVec2 SeparatorTextAlign;
        ImVec2 SeparatorTextPadding;
        ImVec2 DisplayWindowPadding;
        ImVec2 DisplaySafeAreaPadding;
        bool DockingNodeHasCloseButton;
        float DockingSeparatorSize;
        float MouseCursorScale;
        bool AntiAliasedLines;
        bool AntiAliasedLinesUseTex;
        bool AntiAliasedFill;
        float CurveTessellationTol;
        float CircleTessellationMaxError;
        ImVec4[ImGuiCol.COUNT] Colors;
        float HoverStationaryDelay;
        float HoverDelayShort;
        float HoverDelayNormal;
        ImGuiHoveredFlags HoverFlagsForTooltipMouse;
        ImGuiHoveredFlags HoverFlagsForTooltipNav;
        float _MainScale;
        float _NextFrameFontSizeBase;
    }

    struct ImFontAtlasBuilder {
        stbrp_context_opaque PackContext;
        ImVector!(stbrp_node_im) PackNodes;
        ImVector!(ImTextureRect) Rects;
        ImVector!(ImFontAtlasRectEntry) RectsIndex;
        ImVector!(char) TempBuffer;
        int RectsIndexFreeListStart;
        int RectsPackedCount;
        int RectsPackedSurface;
        int RectsDiscardedCount;
        int RectsDiscardedSurface;
        int FrameCount;
        ImVec2i MaxRectSize;
        ImVec2i MaxRectBounds;
        bool LockDisableResize;
        bool PreloadedAllGlyphsRanges;
        ImStableVector!(ImFontBaked, 32) BakedPool;
        ImGuiStorage BakedMap;
        int BakedDiscardedCount;
        ImFontAtlasRectId PackIdMouseCursors;
        ImFontAtlasRectId PackIdLinesTexData;
    }

    struct ImGuiDebugAllocEntry {
        int FrameCount;
        ImS16 AllocCount;
        ImS16 FreeCount;
    }

    struct ImGuiContext {
        bool Initialized;
        bool WithinFrameScope;
        bool WithinFrameScopeWithImplicitWindow;
        bool TestEngineHookItems;
        int FrameCount;
        int FrameCountEnded;
        int FrameCountPlatformEnded;
        int FrameCountRendered;
        double Time;
        char[16] ContextName;
        ImGuiIO IO;
        ImGuiPlatformIO PlatformIO;
        ImGuiStyle Style;
        ImGuiConfigFlags ConfigFlagsCurrFrame;
        ImGuiConfigFlags ConfigFlagsLastFrame;
        ImVector!(ImFontAtlas*) FontAtlases;
        ImFont* Font;
        ImFontBaked* FontBaked;
        float FontSize;
        float FontSizeBase;
        float FontBakedScale;
        float FontRasterizerDensity;
        float CurrentDpiScale;
        ImDrawListSharedData DrawListSharedData;
        ImGuiID WithinEndChildID;
        ImGuiID WithinEndPopupID;
        void* TestEngine;
        ImVector!(ImGuiInputEvent) InputEventsQueue;
        ImVector!(ImGuiInputEvent) InputEventsTrail;
        ImGuiMouseSource InputEventsNextMouseSource;
        ImU32 InputEventsNextEventId;
        ImVector!(ImGuiWindow*) Windows;
        ImVector!(ImGuiWindow*) WindowsFocusOrder;
        ImVector!(ImGuiWindow*) WindowsTempSortBuffer;
        ImVector!(ImGuiWindowStackData) CurrentWindowStack;
        ImGuiStorage WindowsById;
        int WindowsActiveCount;
        float WindowsBorderHoverPadding;
        ImGuiID DebugBreakInWindow;
        ImGuiWindow* CurrentWindow;
        ImGuiWindow* HoveredWindow;
        ImGuiWindow* HoveredWindowUnderMovingWindow;
        ImGuiWindow* HoveredWindowBeforeClear;
        ImGuiWindow* MovingWindow;
        ImGuiWindow* WheelingWindow;
        ImVec2 WheelingWindowRefMousePos;
        int WheelingWindowStartFrame;
        int WheelingWindowScrolledFrame;
        float WheelingWindowReleaseTimer;
        ImVec2 WheelingWindowWheelRemainder;
        ImVec2 WheelingAxisAvg;
        ImGuiID DebugDrawIdConflictsId;
        ImGuiID DebugHookIdInfoId;
        ImGuiID HoveredId;
        ImGuiID HoveredIdPreviousFrame;
        int HoveredIdPreviousFrameItemCount;
        float HoveredIdTimer;
        float HoveredIdNotActiveTimer;
        bool HoveredIdAllowOverlap;
        bool HoveredIdIsDisabled;
        bool ItemUnclipByLog;
        bool AnyIdHasBeenEditedThisFrame;
        ImGuiID ActiveId;
        ImGuiID ActiveIdIsAlive;
        float ActiveIdTimer;
        bool ActiveIdIsJustActivated;
        bool ActiveIdWasSelected;
        bool ActiveIdWasSoleSelected;
        bool ActiveIdAllowOverlap;
        bool ActiveIdNoClearOnFocusLoss;
        bool ActiveIdHasBeenPressedBefore;
        bool ActiveIdHasBeenEditedBefore;
        bool ActiveIdHasBeenEditedThisFrame;
        bool ActiveIdFromShortcut;
        ImS8 ActiveIdMouseButton;
        ImGuiID ActiveIdDisabledId;
        ImVec2 ActiveIdClickOffset;
        ImGuiInputSource ActiveIdSource;
        ImGuiWindow* ActiveIdWindow;
        ImGuiID ActiveIdPreviousFrame;
        ImGuiDeactivatedItemData DeactivatedItemData;
        ImGuiDataTypeStorage ActiveIdValueOnActivation;
        ImGuiID LastActiveId;
        float LastActiveIdTimer;
        bool LastActiveIdWasSelected;
        bool LastActiveIdWasSoleSelected;
        double LastKeyModsChangeTime;
        double LastKeyModsChangeFromNoneTime;
        double LastKeyboardKeyPressTime;
        ImBitArrayForNamedKeys KeysMayBeCharInput;
        ImGuiKeyOwnerData[ImGuiKey.NamedKey_COUNT] KeysOwnerData;
        ImGuiKeyRoutingTable KeysRoutingTable;
        ImU32 ActiveIdUsingNavDirMask;
        bool ActiveIdUsingAllKeyboardKeys;
        ImGuiKeyChord DebugBreakInShortcutRouting;
        ImGuiID CurrentFocusScopeId;
        ImGuiItemFlags CurrentItemFlags;
        ImGuiID DebugLocateId;
        ImGuiNextItemData NextItemData;
        ImGuiLastItemData LastItemData;
        ImGuiNextWindowData NextWindowData;
        bool DebugShowGroupRects;
        bool GcCompactAll;
        ImGuiCol DebugFlashStyleColorIdx;
        ImVector!(ImGuiColorMod) ColorStack;
        ImVector!(ImGuiStyleMod) StyleVarStack;
        ImVector!(ImFontStackData) FontStack;
        ImVector!(ImGuiFocusScopeData) FocusScopeStack;
        ImVector!(ImGuiItemFlags) ItemFlagsStack;
        ImVector!(ImGuiGroupData) GroupStack;
        ImVector!(ImGuiPopupData) OpenPopupStack;
        ImVector!(ImGuiPopupData) BeginPopupStack;
        ImVector!(ImGuiTreeNodeStackData) TreeNodeStack;
        ImVector!(ImGuiViewportP*) Viewports;
        ImGuiViewportP* CurrentViewport;
        ImGuiViewportP* MouseViewport;
        ImGuiViewportP* MouseLastHoveredViewport;
        ImGuiID PlatformLastFocusedViewportId;
        ImGuiPlatformMonitor FallbackMonitor;
        ImRect PlatformMonitorsFullWorkRect;
        int ViewportCreatedCount;
        int PlatformWindowsCreatedCount;
        int ViewportFocusedStampCount;
        bool NavCursorVisible;
        bool NavHighlightItemUnderNav;
        bool NavMousePosDirty;
        bool NavIdIsAlive;
        ImGuiID NavId;
        ImGuiWindow* NavWindow;
        ImGuiID NavFocusScopeId;
        ImGuiNavLayer NavLayer;
        ImGuiItemFlags NavIdItemFlags;
        ImGuiID NavActivateId;
        ImGuiID NavActivateDownId;
        ImGuiID NavActivatePressedId;
        ImGuiActivateFlags NavActivateFlags;
        ImVector!(ImGuiFocusScopeData) NavFocusRoute;
        ImGuiID NavHighlightActivatedId;
        float NavHighlightActivatedTimer;
        ImGuiID NavOpenContextMenuItemId;
        ImGuiID NavOpenContextMenuWindowId;
        ImGuiID NavNextActivateId;
        ImGuiActivateFlags NavNextActivateFlags;
        ImGuiInputSource NavInputSource;
        ImGuiSelectionUserData NavLastValidSelectionUserData;
        ImS8 NavCursorHideFrames;
        bool NavAnyRequest;
        bool NavInitRequest;
        bool NavInitRequestFromMove;
        ImGuiNavItemData NavInitResult;
        bool NavMoveSubmitted;
        bool NavMoveScoringItems;
        bool NavMoveForwardToNextFrame;
        ImGuiNavMoveFlags NavMoveFlags;
        ImGuiScrollFlags NavMoveScrollFlags;
        ImGuiKeyChord NavMoveKeyMods;
        ImGuiDir NavMoveDir;
        ImGuiDir NavMoveDirForDebug;
        ImGuiDir NavMoveClipDir;
        ImRect NavScoringRect;
        ImRect NavScoringNoClipRect;
        int NavScoringDebugCount;
        int NavTabbingDir;
        int NavTabbingCounter;
        ImGuiNavItemData NavMoveResultLocal;
        ImGuiNavItemData NavMoveResultLocalVisible;
        ImGuiNavItemData NavMoveResultOther;
        ImGuiNavItemData NavTabbingResultFirst;
        ImGuiID NavJustMovedFromFocusScopeId;
        ImGuiID NavJustMovedToId;
        ImGuiID NavJustMovedToFocusScopeId;
        ImGuiKeyChord NavJustMovedToKeyMods;
        bool NavJustMovedToIsTabbing;
        bool NavJustMovedToHasSelectionData;
        bool ConfigNavEnableTabbing;
        bool ConfigNavWindowingWithGamepad;
        ImGuiKeyChord ConfigNavWindowingKeyNext;
        ImGuiKeyChord ConfigNavWindowingKeyPrev;
        ImGuiWindow* NavWindowingTarget;
        ImGuiWindow* NavWindowingTargetAnim;
        ImGuiWindow* NavWindowingListWindow;
        float NavWindowingTimer;
        float NavWindowingHighlightAlpha;
        ImGuiInputSource NavWindowingInputSource;
        bool NavWindowingToggleLayer;
        ImGuiKey NavWindowingToggleKey;
        ImVec2 NavWindowingAccumDeltaPos;
        ImVec2 NavWindowingAccumDeltaSize;
        float DimBgRatio;
        bool DragDropActive;
        bool DragDropWithinSource;
        bool DragDropWithinTarget;
        ImGuiDragDropFlags DragDropSourceFlags;
        int DragDropSourceFrameCount;
        int DragDropMouseButton;
        ImGuiPayload DragDropPayload;
        ImRect DragDropTargetRect;
        ImRect DragDropTargetClipRect;
        ImGuiID DragDropTargetId;
        ImGuiID DragDropTargetFullViewport;
        ImGuiDragDropFlags DragDropAcceptFlagsCurr;
        ImGuiDragDropFlags DragDropAcceptFlagsPrev;
        float DragDropAcceptIdCurrRectSurface;
        ImGuiID DragDropAcceptIdCurr;
        ImGuiID DragDropAcceptIdPrev;
        int DragDropAcceptFrameCount;
        ImGuiID DragDropHoldJustPressedId;
        ImVector!(char) DragDropPayloadBufHeap;
        char[16] DragDropPayloadBufLocal;
        int ClipperTempDataStacked;
        ImVector!(ImGuiListClipperData) ClipperTempData;
        ImGuiTable* CurrentTable;
        ImGuiID DebugBreakInTable;
        int TablesTempDataStacked;
        ImVector!(ImGuiTableTempData) TablesTempData;
        ImPool_ImGuiTable Tables;
        ImVector!(float) TablesLastTimeActive;
        ImVector!(ImDrawChannel) DrawChannelsTempMergeBuffer;
        ImGuiTabBar* CurrentTabBar;
        ImPool_ImGuiTabBar TabBars;
        ImVector!(ImGuiPtrOrIndex) CurrentTabBarStack;
        ImVector!(ImGuiShrinkWidthItem) ShrinkWidthBuffer;
        ImGuiBoxSelectState BoxSelectState;
        ImGuiMultiSelectTempData* CurrentMultiSelect;
        int MultiSelectTempDataStacked;
        ImVector!(ImGuiMultiSelectTempData) MultiSelectTempData;
        ImPool_ImGuiMultiSelectState MultiSelectStorage;
        ImGuiID HoverItemDelayId;
        ImGuiID HoverItemDelayIdPreviousFrame;
        float HoverItemDelayTimer;
        float HoverItemDelayClearTimer;
        ImGuiID HoverItemUnlockedStationaryId;
        ImGuiID HoverWindowUnlockedStationaryId;
        ImGuiMouseCursor MouseCursor;
        float MouseStationaryTimer;
        ImVec2 MouseLastValidPos;
        ImGuiInputTextState InputTextState;
        ImGuiTextIndex InputTextLineIndex;
        ImGuiInputTextDeactivatedState InputTextDeactivatedState;
        ImFontBaked InputTextPasswordFontBackupBaked;
        ImFontFlags InputTextPasswordFontBackupFlags;
        ImGuiID InputTextReactivateId;
        ImGuiID TempInputId;
        ImGuiDataTypeStorage DataTypeZeroValue;
        int BeginMenuDepth;
        int BeginComboDepth;
        ImGuiID ColorEditCurrentID;
        ImGuiID ColorEditSavedID;
        float ColorEditSavedHue;
        float ColorEditSavedSat;
        ImU32 ColorEditSavedColor;
        ImVec4 ColorPickerRef;
        ImGuiComboPreviewData ComboPreviewData;
        ImRect WindowResizeBorderExpectedRect;
        bool WindowResizeRelativeMode;
        short ScrollbarSeekMode;
        float ScrollbarClickDeltaToGrabCenter;
        float SliderGrabClickOffset;
        float SliderCurrentAccum;
        bool SliderCurrentAccumDirty;
        bool DragCurrentAccumDirty;
        float DragCurrentAccum;
        float DragSpeedDefaultRatio;
        float DisabledAlphaBackup;
        short DisabledStackSize;
        short TooltipOverrideCount;
        ImGuiWindow* TooltipPreviousWindow;
        ImVector!(char) ClipboardHandlerData;
        ImVector!(ImGuiID) MenusIdSubmittedThisFrame;
        ImGuiTypingSelectState TypingSelectState;
        ImGuiPlatformImeData PlatformImeData;
        ImGuiPlatformImeData PlatformImeDataPrev;
        ImVector!(ImTextureData*) UserTextures;
        ImGuiDockContext DockContext;
        void function(ImGuiContext* ctx,ImGuiDockNode* node,ImGuiTabBar* tab_bar) DockNodeWindowMenuHandler;
        ImGuiPackedDate SessionDate;
        bool SettingsLoaded;
        float SettingsDirtyTimer;
        ImGuiTextBuffer SettingsIniData;
        ImVector!(ImGuiSettingsHandler) SettingsHandlers;
        ImChunkStream_ImGuiWindowSettings SettingsWindows;
        ImChunkStream_ImGuiTableSettings SettingsTables;
        ImVector!(ImGuiContextHook) Hooks;
        ImGuiID HookIdNext;
        ImGuiDemoMarkerCallback DemoMarkerCallback;
        const(char)*[ImGuiLocKey.COUNT] LocalizationTable;
        bool LogEnabled;
        bool LogLineFirstItem;
        ImGuiLogFlags LogFlags;
        ImGuiWindow* LogWindow;
        ImFileHandle LogFile;
        ImGuiTextBuffer LogBuffer;
        const(char)* LogNextPrefix;
        const(char)* LogNextSuffix;
        float LogLinePosY;
        int LogDepthRef;
        int LogDepthToExpand;
        int LogDepthToExpandDefault;
        ImGuiErrorCallback ErrorCallback;
        void* ErrorCallbackUserData;
        ImVec2 ErrorTooltipLockedPos;
        bool ErrorFirst;
        int ErrorCountCurrentFrame;
        ImGuiErrorRecoveryState StackSizesInNewFrame;
        ImGuiErrorRecoveryState* StackSizesInBeginForCurrentWindow;
        int DebugDrawIdConflictsCount;
        ImGuiDebugLogFlags DebugLogFlags;
        ImGuiTextBuffer DebugLogBuf;
        ImGuiTextIndex DebugLogIndex;
        int DebugLogSkippedErrors;
        ImGuiDebugLogFlags DebugLogAutoDisableFlags;
        ImU8 DebugLogAutoDisableFrames;
        ImU8 DebugLocateFrames;
        bool DebugBreakInLocateId;
        ImGuiKeyChord DebugBreakKeyChord;
        ImS8 DebugBeginReturnValueCullDepth;
        bool DebugItemPickerActive;
        ImU8 DebugItemPickerMouseButton;
        ImGuiID DebugItemPickerBreakId;
        float DebugFlashStyleColorTime;
        ImVec4 DebugFlashStyleColorBackup;
        ImGuiMetricsConfig DebugMetricsConfig;
        ImGuiDebugItemPathQuery DebugItemPathQuery;
        ImGuiIDStackTool DebugIDStackTool;
        ImGuiDebugAllocInfo DebugAllocInfo;
        ImGuiDockNode* DebugHoveredDockNode;
        float[60] FramerateSecPerFrame;
        int FramerateSecPerFrameIdx;
        int FramerateSecPerFrameCount;
        float FramerateSecPerFrameAccum;
        int WantCaptureMouseNextFrame;
        int WantCaptureKeyboardNextFrame;
        int WantTextInputNextFrame;
        ImVector!(char) TempBuffer;
        char[64] TempKeychordName;
    }

    struct ImGuiTableColumn {
        ImGuiTableColumnFlags Flags;
        float WidthGiven;
        float MinX;
        float MaxX;
        float WidthRequest;
        float WidthAuto;
        float WidthMax;
        float StretchWeight;
        float InitStretchWeightOrWidth;
        ImRect ClipRect;
        ImGuiID ID;
        ImGuiID UserData;
        float WorkMinX;
        float WorkMaxX;
        float ItemWidth;
        float ContentMaxXFrozen;
        float ContentMaxXUnfrozen;
        float ContentMaxXHeadersUsed;
        float ContentMaxXHeadersIdeal;
        ImS16 NameOffset;
        ImGuiTableColumnIdx DisplayOrder;
        ImGuiTableColumnIdx IndexWithinEnabledSet;
        ImGuiTableColumnIdx PrevEnabledColumn;
        ImGuiTableColumnIdx NextEnabledColumn;
        ImGuiTableColumnIdx SortOrder;
        ImGuiTableDrawChannelIdx DrawChannelCurrent;
        ImGuiTableDrawChannelIdx DrawChannelFrozen;
        ImGuiTableDrawChannelIdx DrawChannelUnfrozen;
        bool IsEnabled;
        bool IsUserEnabled;
        bool IsUserEnabledNextFrame;
        bool IsVisibleX;
        bool IsVisibleY;
        bool IsRequestOutput;
        bool IsSkipItems;
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //bool IsPreserveWidthAuto : 1;
        //bool IsJustCreated : 1;
        //bool IsLoadedSettings : 1;
        //bool IsNeedReconcileSrc : 1;
        //bool IsNeedReconcileDst : 1;
        bool bitfield_0;
        @property bool IsPreserveWidthAuto() { return GetValue!bool(bitfield_0, 0, 1); }
        @property void IsPreserveWidthAuto(bool aValue) { bitfield_0 = SetValue(bitfield_0, 0, 1, aValue); };
        @property bool IsJustCreated() { return GetValue!bool(bitfield_0, 1, 1); }
        @property void IsJustCreated(bool aValue) { bitfield_0 = SetValue(bitfield_0, 1, 1, aValue); };
        @property bool IsLoadedSettings() { return GetValue!bool(bitfield_0, 2, 1); }
        @property void IsLoadedSettings(bool aValue) { bitfield_0 = SetValue(bitfield_0, 2, 1, aValue); };
        @property bool IsNeedReconcileSrc() { return GetValue!bool(bitfield_0, 3, 1); }
        @property void IsNeedReconcileSrc(bool aValue) { bitfield_0 = SetValue(bitfield_0, 3, 1, aValue); };
        @property bool IsNeedReconcileDst() { return GetValue!bool(bitfield_0, 4, 1); }
        @property void IsNeedReconcileDst(bool aValue) { bitfield_0 = SetValue(bitfield_0, 4, 1, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 5.sizeof);
        ImS8 NavLayerCurrent;
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //ImU8 AutoFitQueue : 4;
        //ImU8 CannotSkipItemsQueue : 4;
        //ImU8 SortDirection : 2;
        //ImU8 SortDirectionsAvailCount : 2;
        //ImU8 SortDirectionsAvailMask : 4;
        ImU8 bitfield_1;
        @property ImU8 AutoFitQueue() { return GetValue!ImU8(bitfield_1, 0, 4); }
        @property void AutoFitQueue(ImU8 aValue) { bitfield_1 = SetValue(bitfield_1, 0, 4, aValue); };
        @property ImU8 CannotSkipItemsQueue() { return GetValue!ImU8(bitfield_1, 4, 4); }
        @property void CannotSkipItemsQueue(ImU8 aValue) { bitfield_1 = SetValue(bitfield_1, 4, 4, aValue); };
        @property ImU8 SortDirection() { return GetValue!ImU8(bitfield_1, 8, 2); }
        @property void SortDirection(ImU8 aValue) { bitfield_1 = SetValue(bitfield_1, 8, 2, aValue); };
        @property ImU8 SortDirectionsAvailCount() { return GetValue!ImU8(bitfield_1, 10, 2); }
        @property void SortDirectionsAvailCount(ImU8 aValue) { bitfield_1 = SetValue(bitfield_1, 10, 2, aValue); };
        @property ImU8 SortDirectionsAvailMask() { return GetValue!ImU8(bitfield_1, 12, 4); }
        @property void SortDirectionsAvailMask(ImU8 aValue) { bitfield_1 = SetValue(bitfield_1, 12, 4, aValue); };
        static assert((bitfield_1.sizeof * 8) >= 16.sizeof);
        ImU8 SortDirectionsAvailList;
    }

    struct ImGuiTableSortSpecs {
        const ImGuiTableColumnSortSpecs* Specs;
        int SpecsCount;
        bool SpecsDirty;
    }

    struct ImFontAtlasRectEntry {
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //int TargetIndex : 20;
        int bitfield_0;
        @property int TargetIndex() { return GetValue!int(bitfield_0, 0, 20); }
        @property void TargetIndex(int aValue) { bitfield_0 = SetValue(bitfield_0, 0, 20, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 20.sizeof);
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //uint Generation : 10;
        //uint IsUsed : 1;
        uint bitfield_1;
        @property uint Generation() { return GetValue!uint(bitfield_1, 0, 10); }
        @property void Generation(uint aValue) { bitfield_1 = SetValue(bitfield_1, 0, 10, aValue); };
        @property uint IsUsed() { return GetValue!uint(bitfield_1, 10, 1); }
        @property void IsUsed(uint aValue) { bitfield_1 = SetValue(bitfield_1, 10, 1, aValue); };
        static assert((bitfield_1.sizeof * 8) >= 11.sizeof);
    }

    struct ImGuiTableColumnSortSpecs {
        ImGuiID ColumnUserID;
        ImS16 ColumnIndex;
        ImS16 SortOrder;
        ImGuiSortDirection SortDirection;
    }

    struct ImGuiMultiSelectTempData {
        ImGuiMultiSelectIO IO;
        ImGuiMultiSelectState* Storage;
        ImGuiID FocusScopeId;
        ImGuiMultiSelectFlags Flags;
        ImVec2 ScopeRectMin;
        ImVec2 BackupCursorMaxPos;
        ImGuiID BoxSelectId;
        ImGuiKeyChord KeyMods;
        ImS8 LoopRequestSetAll;
        bool IsEndIO;
        bool IsFocused;
        bool IsKeyboardSetRange;
        bool NavIdPassedBy;
        bool RangeSrcPassedBy;
        bool RangeDstPassedBy;
        bool IsSoleOrUnknownSelectionSize;
    }

    struct ImGuiOnceUponAFrame {
        int RefFrame;
    }

    struct ImGuiWindowSettings {
        ImGuiID ID;
        ImVec2ih Pos;
        ImVec2ih Size;
        ImVec2ih ViewportPos;
        ImGuiID ViewportId;
        ImGuiID DockId;
        ImGuiID ClassId;
        short DockOrder;
        ImGuiPackedDate LastUsedDate;
        // This is a bitfield, we cannot replicate this in the D binding, but we're providing properties to easily access the fields.
        //bool Collapsed : 1;
        //bool IsChild : 1;
        //bool WantApply : 1;
        //bool WantDelete : 1;
        bool bitfield_0;
        @property bool Collapsed() { return GetValue!bool(bitfield_0, 0, 1); }
        @property void Collapsed(bool aValue) { bitfield_0 = SetValue(bitfield_0, 0, 1, aValue); };
        @property bool IsChild() { return GetValue!bool(bitfield_0, 1, 1); }
        @property void IsChild(bool aValue) { bitfield_0 = SetValue(bitfield_0, 1, 1, aValue); };
        @property bool WantApply() { return GetValue!bool(bitfield_0, 2, 1); }
        @property void WantApply(bool aValue) { bitfield_0 = SetValue(bitfield_0, 2, 1, aValue); };
        @property bool WantDelete() { return GetValue!bool(bitfield_0, 3, 1); }
        @property void WantDelete(bool aValue) { bitfield_0 = SetValue(bitfield_0, 3, 1, aValue); };
        static assert((bitfield_0.sizeof * 8) >= 4.sizeof);
    }

    struct ImGuiPlatformImeData {
        bool WantVisible;
        bool WantTextInput;
        ImVec2 InputPos;
        float InputLineHeight;
        ImGuiID ViewportId;
    }

    struct ImDrawList {
        ImVector!(ImDrawCmd) CmdBuffer;
        ImVector!(ImDrawIdx) IdxBuffer;
        ImVector!(ImDrawVert) VtxBuffer;
        ImDrawListFlags Flags;
        uint _VtxCurrentIdx;
        ImDrawListSharedData* _Data;
        ImDrawVert* _VtxWritePtr;
        ImDrawIdx* _IdxWritePtr;
        ImVector!(ImVec2) _Path;
        ImDrawCmdHeader _CmdHeader;
        ImDrawListSplitter _Splitter;
        ImVector!(ImVec4) _ClipRectStack;
        ImVector!(ImTextureRef) _TextureStack;
        ImVector!(ImU8) _CallbacksDataBuf;
        float _FringeScale;
        const(char)* _OwnerName;
    }

    struct ImGuiTypingSelectState {
        ImGuiTypingSelectRequest Request;
        char[64] SearchBuffer;
        ImGuiID FocusScope;
        int LastRequestFrame;
        float LastRequestTime;
        bool SingleCharModeLock;
    }

    struct ImGuiTableReconcileColumnData {
        ImGuiID ID;
        ImS16 NameOffset;
        ImGuiTableColumnFlags Flags;
        float InitWidthOrWeight;
        ImGuiID UserData;
        ImGuiTableColumnIdx ColumnNewIdx;
        ImGuiTableColumnIdx ColumnOldIdx;
        ImGuiTableColumn ColumnOldData;
    }

    struct ImGuiMenuColumns {
        ImU32 TotalWidth;
        ImU32 NextTotalWidth;
        ImU16 Spacing;
        ImU16 OffsetIcon;
        ImU16 OffsetLabel;
        ImU16 OffsetShortcut;
        ImU16 OffsetMark;
        ImU16[4] Widths;
    }

    struct ImGuiInputEventMouseViewport {
        ImGuiID HoveredViewportID;
    }

    struct ImGuiTabItem {
        ImGuiID ID;
        ImGuiTabItemFlags Flags;
        ImGuiWindow* Window;
        int LastFrameVisible;
        int LastFrameSelected;
        float Offset;
        float Width;
        float ContentWidth;
        float RequestedWidth;
        ImS32 NameOffset;
        ImS16 BeginOrder;
        ImS16 IndexDuringLayout;
        bool WantClose;
    }

    struct ImGuiInputEventMousePos {
        float PosX;
        float PosY;
        ImGuiMouseSource MouseSource;
    }

    struct ImGuiWindowDockStyle {
        ImU32[ImGuiWindowDockStyleCol.COUNT] Colors;
    }


}
extern (C) @nogc nothrow {
    void ImBitVector_Clear(ImBitVector* self);
    void ImBitVector_ClearBit(ImBitVector* self, int n);
    void ImBitVector_Create(ImBitVector* self, int sz);
    void ImBitVector_SetBit(ImBitVector* self, int n);
    bool ImBitVector_TestBit(ImBitVector* self, int n);
    ImColor ImColor_HSV(float h, float s, float v, float a = 1.0f);
    ImColor* ImColor_ImColor_Nil();
    ImColor* ImColor_ImColor_Float(float r, float g, float b, float a = 1.0f);
    ImColor* ImColor_ImColor_Vec4(const ImVec4 col);
    ImColor* ImColor_ImColor_Int(int r, int g, int b, int a = 255);
    ImColor* ImColor_ImColor_U32(ImU32 rgba);
    void ImColor_SetHSV(ImColor* self, float h, float s, float v, float a = 1.0f);
    void ImColor_destroy(ImColor* self);
    ImTextureID ImDrawCmd_GetTexID(ImDrawCmd* self);
    ImDrawCmd* ImDrawCmd_ImDrawCmd();
    void ImDrawCmd_destroy(ImDrawCmd* self);
    ImDrawDataBuilder* ImDrawDataBuilder_ImDrawDataBuilder();
    void ImDrawDataBuilder_destroy(ImDrawDataBuilder* self);
    void ImDrawData_AddDrawList(ImDrawData* self, ImDrawList* draw_list);
    void ImDrawData_Clear(ImDrawData* self);
    void ImDrawData_DeIndexAllBuffers(ImDrawData* self);
    ImDrawData* ImDrawData_ImDrawData();
    void ImDrawData_ScaleClipRects(ImDrawData* self, const ImVec2 fb_scale);
    void ImDrawData_destroy(ImDrawData* self);
    ImDrawListSharedData* ImDrawListSharedData_ImDrawListSharedData();
    void ImDrawListSharedData_SetCircleTessellationMaxError(ImDrawListSharedData* self, float max_error);
    void ImDrawListSharedData_destroy(ImDrawListSharedData* self);
    void ImDrawListSplitter_Clear(ImDrawListSplitter* self);
    void ImDrawListSplitter_ClearFreeMemory(ImDrawListSplitter* self);
    ImDrawListSplitter* ImDrawListSplitter_ImDrawListSplitter();
    void ImDrawListSplitter_Merge(ImDrawListSplitter* self, ImDrawList* draw_list);
    void ImDrawListSplitter_SetCurrentChannel(ImDrawListSplitter* self, ImDrawList* draw_list, int channel_idx);
    void ImDrawListSplitter_Split(ImDrawListSplitter* self, ImDrawList* draw_list, int count);
    void ImDrawListSplitter_destroy(ImDrawListSplitter* self);
    void ImDrawList_AddBezierCubic(ImDrawList* self, const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, const ImVec2 p4, ImU32 col, float thickness, int num_segments = 0);
    void ImDrawList_AddBezierQuadratic(ImDrawList* self, const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, ImU32 col, float thickness, int num_segments = 0);
    void ImDrawList_AddCallback(ImDrawList* self, ImDrawCallback callback, void* userdata = null, size_t userdata_size = 0);
    void ImDrawList_AddCircle(ImDrawList* self, const ImVec2 center, float radius, ImU32 col, int num_segments = 0, float thickness = 1.0f);
    void ImDrawList_AddCircleFilled(ImDrawList* self, const ImVec2 center, float radius, ImU32 col, int num_segments = 0);
    void ImDrawList_AddConcavePolyFilled(ImDrawList* self, const ImVec2* points, int num_points, ImU32 col);
    void ImDrawList_AddConvexPolyFilled(ImDrawList* self, const ImVec2* points, int num_points, ImU32 col);
    void ImDrawList_AddDrawCmd(ImDrawList* self);
    void ImDrawList_AddEllipse(ImDrawList* self, const ImVec2 center, const ImVec2 radius, ImU32 col, float rot = 0.0f, int num_segments = 0, float thickness = 1.0f);
    void ImDrawList_AddEllipseFilled(ImDrawList* self, const ImVec2 center, const ImVec2 radius, ImU32 col, float rot = 0.0f, int num_segments = 0);
    void ImDrawList_AddImage(ImDrawList* self, ImTextureRef tex_ref, const ImVec2 p_min, const ImVec2 p_max, const ImVec2 uv_min = ImVec2(0,0), const ImVec2 uv_max = ImVec2(1,1), ImU32 col = 4294967295);
    void ImDrawList_AddImageQuad(ImDrawList* self, ImTextureRef tex_ref, const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, const ImVec2 p4, const ImVec2 uv1 = ImVec2(0,0), const ImVec2 uv2 = ImVec2(1,0), const ImVec2 uv3 = ImVec2(1,1), const ImVec2 uv4 = ImVec2(0,1), ImU32 col = 4294967295);
    void ImDrawList_AddImageRounded(ImDrawList* self, ImTextureRef tex_ref, const ImVec2 p_min, const ImVec2 p_max, const ImVec2 uv_min, const ImVec2 uv_max, ImU32 col, float rounding, ImDrawFlags flags = ImDrawFlags.None);
    void ImDrawList_AddLine(ImDrawList* self, const ImVec2 p1, const ImVec2 p2, ImU32 col, float thickness = 1.0f);
    void ImDrawList_AddLineH(ImDrawList* self, float min_x, float max_x, float y, ImU32 col, float thickness = 1.0f);
    void ImDrawList_AddLineV(ImDrawList* self, float x, float min_y, float max_y, ImU32 col, float thickness = 1.0f);
    void ImDrawList_AddNgon(ImDrawList* self, const ImVec2 center, float radius, ImU32 col, int num_segments, float thickness = 1.0f);
    void ImDrawList_AddNgonFilled(ImDrawList* self, const ImVec2 center, float radius, ImU32 col, int num_segments);
    void ImDrawList_AddPolyline(ImDrawList* self, const ImVec2* points, int num_points, ImU32 col, float thickness, ImDrawFlags flags = ImDrawFlags.None);
    void ImDrawList_AddQuad(ImDrawList* self, const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, const ImVec2 p4, ImU32 col, float thickness = 1.0f);
    void ImDrawList_AddQuadFilled(ImDrawList* self, const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, const ImVec2 p4, ImU32 col);
    void ImDrawList_AddRect(ImDrawList* self, const ImVec2 p_min, const ImVec2 p_max, ImU32 col, float rounding = 0.0f, float thickness = 1.0f, ImDrawFlags flags = ImDrawFlags.None);
    void ImDrawList_AddRectFilled(ImDrawList* self, const ImVec2 p_min, const ImVec2 p_max, ImU32 col, float rounding = 0.0f, ImDrawFlags flags = ImDrawFlags.None);
    void ImDrawList_AddRectFilledMultiColor(ImDrawList* self, const ImVec2 p_min, const ImVec2 p_max, ImU32 col_upr_left, ImU32 col_upr_right, ImU32 col_bot_right, ImU32 col_bot_left);
    void ImDrawList_AddText_Vec2(ImDrawList* self, const ImVec2 pos, ImU32 col, const(char)* text_begin, const(char)* text_end = null);
    void ImDrawList_AddText_FontPtr(ImDrawList* self, ImFont* font, float font_size, const ImVec2 pos, ImU32 col, const(char)* text_begin, const(char)* text_end = null, float wrap_width = 0.0f, const(ImVec4)* cpu_fine_clip_rect = null);
    void ImDrawList_AddTriangle(ImDrawList* self, const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, ImU32 col, float thickness = 1.0f);
    void ImDrawList_AddTriangleFilled(ImDrawList* self, const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, ImU32 col);
    void ImDrawList_ChannelsMerge(ImDrawList* self);
    void ImDrawList_ChannelsSetCurrent(ImDrawList* self, int n);
    void ImDrawList_ChannelsSplit(ImDrawList* self, int count);
    ImDrawList* ImDrawList_CloneOutput(ImDrawList* self);
    ImVec2 ImDrawList_GetClipRectMax(ImDrawList* self);
    ImVec2 ImDrawList_GetClipRectMin(ImDrawList* self);
    ImDrawList* ImDrawList_ImDrawList(ImDrawListSharedData* shared_data);
    void ImDrawList_PathArcTo(ImDrawList* self, const ImVec2 center, float radius, float a_min, float a_max, int num_segments = 0);
    void ImDrawList_PathArcToFast(ImDrawList* self, const ImVec2 center, float radius, int a_min_of_12, int a_max_of_12);
    void ImDrawList_PathBezierCubicCurveTo(ImDrawList* self, const ImVec2 p2, const ImVec2 p3, const ImVec2 p4, int num_segments = 0);
    void ImDrawList_PathBezierQuadraticCurveTo(ImDrawList* self, const ImVec2 p2, const ImVec2 p3, int num_segments = 0);
    void ImDrawList_PathClear(ImDrawList* self);
    void ImDrawList_PathEllipticalArcTo(ImDrawList* self, const ImVec2 center, const ImVec2 radius, float rot, float a_min, float a_max, int num_segments = 0);
    void ImDrawList_PathFillConcave(ImDrawList* self, ImU32 col);
    void ImDrawList_PathFillConvex(ImDrawList* self, ImU32 col);
    void ImDrawList_PathLineTo(ImDrawList* self, const ImVec2 pos);
    void ImDrawList_PathLineToMergeDuplicate(ImDrawList* self, const ImVec2 pos);
    void ImDrawList_PathRect(ImDrawList* self, const ImVec2 rect_min, const ImVec2 rect_max, float rounding = 0.0f, ImDrawFlags flags = ImDrawFlags.None);
    void ImDrawList_PathStroke(ImDrawList* self, ImU32 col, float thickness = 1.0f, ImDrawFlags flags = ImDrawFlags.None);
    void ImDrawList_PopClipRect(ImDrawList* self);
    void ImDrawList_PopTexture(ImDrawList* self);
    void ImDrawList_PrimQuadUV(ImDrawList* self, const ImVec2 a, const ImVec2 b, const ImVec2 c, const ImVec2 d, const ImVec2 uv_a, const ImVec2 uv_b, const ImVec2 uv_c, const ImVec2 uv_d, ImU32 col);
    void ImDrawList_PrimRect(ImDrawList* self, const ImVec2 a, const ImVec2 b, ImU32 col);
    void ImDrawList_PrimRectUV(ImDrawList* self, const ImVec2 a, const ImVec2 b, const ImVec2 uv_a, const ImVec2 uv_b, ImU32 col);
    void ImDrawList_PrimReserve(ImDrawList* self, int idx_count, int vtx_count);
    void ImDrawList_PrimUnreserve(ImDrawList* self, int idx_count, int vtx_count);
    void ImDrawList_PrimVtx(ImDrawList* self, const ImVec2 pos, const ImVec2 uv, ImU32 col);
    void ImDrawList_PrimWriteIdx(ImDrawList* self, ImDrawIdx idx);
    void ImDrawList_PrimWriteVtx(ImDrawList* self, const ImVec2 pos, const ImVec2 uv, ImU32 col);
    void ImDrawList_PushClipRect(ImDrawList* self, const ImVec2 clip_rect_min, const ImVec2 clip_rect_max, bool intersect_with_current_clip_rect = false);
    void ImDrawList_PushClipRectFullScreen(ImDrawList* self);
    void ImDrawList_PushTexture(ImDrawList* self, ImTextureRef tex_ref);
    int ImDrawList__CalcCircleAutoSegmentCount(ImDrawList* self, float radius);
    void ImDrawList__ClearFreeMemory(ImDrawList* self);
    void ImDrawList__OnChangedClipRect(ImDrawList* self);
    void ImDrawList__OnChangedTexture(ImDrawList* self);
    void ImDrawList__OnChangedVtxOffset(ImDrawList* self);
    void ImDrawList__PathArcToFastEx(ImDrawList* self, const ImVec2 center, float radius, int a_min_sample, int a_max_sample, int a_step);
    void ImDrawList__PathArcToN(ImDrawList* self, const ImVec2 center, float radius, float a_min, float a_max, int num_segments);
    void ImDrawList__PopUnusedDrawCmd(ImDrawList* self);
    void ImDrawList__ResetForNewFrame(ImDrawList* self);
    void ImDrawList__SetDrawListSharedData(ImDrawList* self, ImDrawListSharedData* data);
    void ImDrawList__SetTexture(ImDrawList* self, ImTextureRef tex_ref);
    void ImDrawList__TryMergeDrawCmds(ImDrawList* self);
    void ImDrawList_destroy(ImDrawList* self);
    ImFontAtlasBuilder* ImFontAtlasBuilder_ImFontAtlasBuilder();
    void ImFontAtlasBuilder_destroy(ImFontAtlasBuilder* self);
    ImFontAtlasRect* ImFontAtlasRect_ImFontAtlasRect();
    void ImFontAtlasRect_destroy(ImFontAtlasRect* self);
    ImFontAtlasRectId ImFontAtlas_AddCustomRect(ImFontAtlas* self, int width, int height, ImFontAtlasRect* out_r = null);
    ImFont* ImFontAtlas_AddFont(ImFontAtlas* self, const ImFontConfig* font_cfg);
    ImFont* ImFontAtlas_AddFontDefault(ImFontAtlas* self, const ImFontConfig* font_cfg = null);
    ImFont* ImFontAtlas_AddFontDefaultBitmap(ImFontAtlas* self, const ImFontConfig* font_cfg = null);
    ImFont* ImFontAtlas_AddFontDefaultVector(ImFontAtlas* self, const ImFontConfig* font_cfg = null);
    ImFont* ImFontAtlas_AddFontFromFileTTF(ImFontAtlas* self, const(char)* filename, float size_pixels = 0.0f, const ImFontConfig* font_cfg = null, const(ImWchar)* glyph_ranges = null);
    ImFont* ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(ImFontAtlas* self, const(char)* compressed_font_data_base85, float size_pixels = 0.0f, const ImFontConfig* font_cfg = null, const(ImWchar)* glyph_ranges = null);
    ImFont* ImFontAtlas_AddFontFromMemoryCompressedTTF(ImFontAtlas* self, const void* compressed_font_data, int compressed_font_data_size, float size_pixels = 0.0f, const ImFontConfig* font_cfg = null, const(ImWchar)* glyph_ranges = null);
    ImFont* ImFontAtlas_AddFontFromMemoryTTF(ImFontAtlas* self, void* font_data, int font_data_size, float size_pixels = 0.0f, const ImFontConfig* font_cfg = null, const(ImWchar)* glyph_ranges = null);
    void ImFontAtlas_Clear(ImFontAtlas* self);
    void ImFontAtlas_ClearFonts(ImFontAtlas* self);
    void ImFontAtlas_ClearInputData(ImFontAtlas* self);
    void ImFontAtlas_ClearTexData(ImFontAtlas* self);
    void ImFontAtlas_CompactCache(ImFontAtlas* self);
    bool ImFontAtlas_GetCustomRect(ImFontAtlas* self, ImFontAtlasRectId id, ImFontAtlasRect* out_r);
    const(ImWchar)* ImFontAtlas_GetGlyphRangesDefault(ImFontAtlas* self);
    ImFontAtlas* ImFontAtlas_ImFontAtlas();
    void ImFontAtlas_RemoveCustomRect(ImFontAtlas* self, ImFontAtlasRectId id);
    void ImFontAtlas_RemoveFont(ImFontAtlas* self, ImFont* font);
    void ImFontAtlas_SetFontLoader(ImFontAtlas* self, const(ImFontLoader)* font_loader);
    void ImFontAtlas_destroy(ImFontAtlas* self);
    void ImFontBaked_ClearOutputData(ImFontBaked* self);
    ImFontGlyph* ImFontBaked_FindGlyph(ImFontBaked* self, ImWchar c);
    ImFontGlyph* ImFontBaked_FindGlyphNoFallback(ImFontBaked* self, ImWchar c);
    float ImFontBaked_GetCharAdvance(ImFontBaked* self, ImWchar c);
    ImFontBaked* ImFontBaked_ImFontBaked();
    bool ImFontBaked_IsGlyphLoaded(ImFontBaked* self, ImWchar c);
    void ImFontBaked_destroy(ImFontBaked* self);
    ImFontConfig* ImFontConfig_ImFontConfig();
    void ImFontConfig_destroy(ImFontConfig* self);
    void ImFontGlyphRangesBuilder_AddChar(ImFontGlyphRangesBuilder* self, ImWchar c);
    void ImFontGlyphRangesBuilder_AddRanges(ImFontGlyphRangesBuilder* self, const(ImWchar)* ranges);
    void ImFontGlyphRangesBuilder_AddText(ImFontGlyphRangesBuilder* self, const(char)* text, const(char)* text_end = null);
    void ImFontGlyphRangesBuilder_BuildRanges(ImFontGlyphRangesBuilder* self, ImVector!(ImWchar)* out_ranges);
    void ImFontGlyphRangesBuilder_Clear(ImFontGlyphRangesBuilder* self);
    bool ImFontGlyphRangesBuilder_GetBit(ImFontGlyphRangesBuilder* self, size_t n);
    ImFontGlyphRangesBuilder* ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder();
    void ImFontGlyphRangesBuilder_SetBit(ImFontGlyphRangesBuilder* self, size_t n);
    void ImFontGlyphRangesBuilder_destroy(ImFontGlyphRangesBuilder* self);
    ImFontGlyph* ImFontGlyph_ImFontGlyph();
    void ImFontGlyph_destroy(ImFontGlyph* self);
    ImFontLoader* ImFontLoader_ImFontLoader();
    void ImFontLoader_destroy(ImFontLoader* self);
    void ImFont_AddRemapChar(ImFont* self, ImWchar from_codepoint, ImWchar to_codepoint);
    ImVec2 ImFont_CalcTextSizeA(ImFont* self, float size, float max_width, float wrap_width, const(char)* text_begin, const(char)* text_end = null, const char** out_remaining = null);
    const(char)* ImFont_CalcWordWrapPosition(ImFont* self, float size, const(char)* text, const(char)* text_end, float wrap_width);
    void ImFont_ClearOutputData(ImFont* self);
    const(char)* ImFont_GetDebugName(ImFont* self);
    ImFontBaked* ImFont_GetFontBaked(ImFont* self, float font_size, float density = -1.0f);
    ImFont* ImFont_ImFont();
    bool ImFont_IsGlyphInFont(ImFont* self, ImWchar c);
    bool ImFont_IsGlyphRangeUnused(ImFont* self, uint c_begin, uint c_last);
    bool ImFont_IsLoaded(ImFont* self);
    void ImFont_RenderChar(ImFont* self, ImDrawList* draw_list, float size, const ImVec2 pos, ImU32 col, ImWchar c, const(ImVec4)* cpu_fine_clip = null);
    void ImFont_RenderText(ImFont* self, ImDrawList* draw_list, float size, const ImVec2 pos, ImU32 col, const ImVec4 clip_rect, const(char)* text_begin, const(char)* text_end, float wrap_width = 0.0f, ImDrawTextFlags flags = ImDrawTextFlags.None);
    void ImFont_destroy(ImFont* self);
    ImGuiBoxSelectState* ImGuiBoxSelectState_ImGuiBoxSelectState();
    void ImGuiBoxSelectState_destroy(ImGuiBoxSelectState* self);
    ImGuiComboPreviewData* ImGuiComboPreviewData_ImGuiComboPreviewData();
    void ImGuiComboPreviewData_destroy(ImGuiComboPreviewData* self);
    ImGuiContextHook* ImGuiContextHook_ImGuiContextHook();
    void ImGuiContextHook_destroy(ImGuiContextHook* self);
    ImGuiContext* ImGuiContext_ImGuiContext(ImFontAtlas* shared_font_atlas);
    void ImGuiContext_destroy(ImGuiContext* self);
    ImGuiDebugAllocInfo* ImGuiDebugAllocInfo_ImGuiDebugAllocInfo();
    void ImGuiDebugAllocInfo_destroy(ImGuiDebugAllocInfo* self);
    ImGuiDebugItemPathQuery* ImGuiDebugItemPathQuery_ImGuiDebugItemPathQuery();
    void ImGuiDebugItemPathQuery_destroy(ImGuiDebugItemPathQuery* self);
    ImGuiDockContext* ImGuiDockContext_ImGuiDockContext();
    void ImGuiDockContext_destroy(ImGuiDockContext* self);
    ImGuiDockNode* ImGuiDockNode_ImGuiDockNode(ImGuiID id);
    bool ImGuiDockNode_IsCentralNode(ImGuiDockNode* self);
    bool ImGuiDockNode_IsDockSpace(ImGuiDockNode* self);
    bool ImGuiDockNode_IsEmpty(ImGuiDockNode* self);
    bool ImGuiDockNode_IsFloatingNode(ImGuiDockNode* self);
    bool ImGuiDockNode_IsHiddenTabBar(ImGuiDockNode* self);
    bool ImGuiDockNode_IsLeafNode(ImGuiDockNode* self);
    bool ImGuiDockNode_IsNoTabBar(ImGuiDockNode* self);
    bool ImGuiDockNode_IsRootNode(ImGuiDockNode* self);
    bool ImGuiDockNode_IsSplitNode(ImGuiDockNode* self);
    ImRect ImGuiDockNode_Rect(ImGuiDockNode* self);
    void ImGuiDockNode_SetLocalFlags(ImGuiDockNode* self, ImGuiDockNodeFlags flags);
    void ImGuiDockNode_UpdateMergedFlags(ImGuiDockNode* self);
    void ImGuiDockNode_destroy(ImGuiDockNode* self);
    ImGuiErrorRecoveryState* ImGuiErrorRecoveryState_ImGuiErrorRecoveryState();
    void ImGuiErrorRecoveryState_destroy(ImGuiErrorRecoveryState* self);
    bool ImGuiFreeType_DebugEditFontLoaderFlags(ImGuiFreeTypeLoaderFlags* p_font_loader_flags);
    const(ImFontLoader)* ImGuiFreeType_GetFontLoader();
    void ImGuiFreeType_SetAllocatorFunctions(void* function(size_t sz,void* user_data) alloc_func, void function(void* ptr,void* user_data) free_func, void* user_data = null);
    ImGuiIDStackTool* ImGuiIDStackTool_ImGuiIDStackTool();
    void ImGuiIDStackTool_destroy(ImGuiIDStackTool* self);
    void ImGuiIO_AddFocusEvent(ImGuiIO* self, bool focused);
    void ImGuiIO_AddInputCharacter(ImGuiIO* self, uint c);
    void ImGuiIO_AddInputCharacterUTF16(ImGuiIO* self, ImWchar16 c);
    void ImGuiIO_AddInputCharactersUTF8(ImGuiIO* self, const(char)* str);
    void ImGuiIO_AddKeyAnalogEvent(ImGuiIO* self, ImGuiKey key, bool down, float v);
    void ImGuiIO_AddKeyEvent(ImGuiIO* self, ImGuiKey key, bool down);
    void ImGuiIO_AddMouseButtonEvent(ImGuiIO* self, int button, bool down);
    void ImGuiIO_AddMousePosEvent(ImGuiIO* self, float x, float y);
    void ImGuiIO_AddMouseSourceEvent(ImGuiIO* self, ImGuiMouseSource source);
    void ImGuiIO_AddMouseViewportEvent(ImGuiIO* self, ImGuiID id);
    void ImGuiIO_AddMouseWheelEvent(ImGuiIO* self, float wheel_x, float wheel_y);
    void ImGuiIO_ClearEventsQueue(ImGuiIO* self);
    void ImGuiIO_ClearInputKeys(ImGuiIO* self);
    void ImGuiIO_ClearInputMouse(ImGuiIO* self);
    ImGuiIO* ImGuiIO_ImGuiIO();
    void ImGuiIO_SetAppAcceptingEvents(ImGuiIO* self, bool accepting_events);
    void ImGuiIO_SetKeyEventNativeData(ImGuiIO* self, ImGuiKey key, int native_keycode, int native_scancode, int native_legacy_index = -1);
    void ImGuiIO_destroy(ImGuiIO* self);
    ImGuiInputEvent* ImGuiInputEvent_ImGuiInputEvent();
    void ImGuiInputEvent_destroy(ImGuiInputEvent* self);
    void ImGuiInputTextCallbackData_ClearSelection(ImGuiInputTextCallbackData* self);
    void ImGuiInputTextCallbackData_DeleteChars(ImGuiInputTextCallbackData* self, int pos, int bytes_count);
    bool ImGuiInputTextCallbackData_HasSelection(ImGuiInputTextCallbackData* self);
    ImGuiInputTextCallbackData* ImGuiInputTextCallbackData_ImGuiInputTextCallbackData();
    void ImGuiInputTextCallbackData_InsertChars(ImGuiInputTextCallbackData* self, int pos, const(char)* text, const(char)* text_end = null);
    void ImGuiInputTextCallbackData_SelectAll(ImGuiInputTextCallbackData* self);
    void ImGuiInputTextCallbackData_SetSelection(ImGuiInputTextCallbackData* self, int s, int e);
    void ImGuiInputTextCallbackData_destroy(ImGuiInputTextCallbackData* self);
    void ImGuiInputTextDeactivatedState_ClearFreeMemory(ImGuiInputTextDeactivatedState* self);
    ImGuiInputTextDeactivatedState* ImGuiInputTextDeactivatedState_ImGuiInputTextDeactivatedState();
    void ImGuiInputTextDeactivatedState_destroy(ImGuiInputTextDeactivatedState* self);
    void ImGuiInputTextState_ClearFreeMemory(ImGuiInputTextState* self);
    void ImGuiInputTextState_ClearSelection(ImGuiInputTextState* self);
    void ImGuiInputTextState_ClearText(ImGuiInputTextState* self);
    void ImGuiInputTextState_CursorAnimReset(ImGuiInputTextState* self);
    void ImGuiInputTextState_CursorClamp(ImGuiInputTextState* self);
    int ImGuiInputTextState_GetCursorPos(ImGuiInputTextState* self);
    float ImGuiInputTextState_GetPreferredOffsetX(ImGuiInputTextState* self);
    int ImGuiInputTextState_GetSelectionEnd(ImGuiInputTextState* self);
    int ImGuiInputTextState_GetSelectionStart(ImGuiInputTextState* self);
    const(char)* ImGuiInputTextState_GetText(ImGuiInputTextState* self);
    bool ImGuiInputTextState_HasSelection(ImGuiInputTextState* self);
    ImGuiInputTextState* ImGuiInputTextState_ImGuiInputTextState();
    void ImGuiInputTextState_OnCharPressed(ImGuiInputTextState* self, uint c);
    void ImGuiInputTextState_OnKeyPressed(ImGuiInputTextState* self, int key);
    void ImGuiInputTextState_ReloadUserBufAndKeepSelection(ImGuiInputTextState* self);
    void ImGuiInputTextState_ReloadUserBufAndMoveToEnd(ImGuiInputTextState* self);
    void ImGuiInputTextState_ReloadUserBufAndSelectAll(ImGuiInputTextState* self);
    void ImGuiInputTextState_SelectAll(ImGuiInputTextState* self);
    void ImGuiInputTextState_SetSelection(ImGuiInputTextState* self, int start, int end);
    void ImGuiInputTextState_destroy(ImGuiInputTextState* self);
    ImGuiKeyOwnerData* ImGuiKeyOwnerData_ImGuiKeyOwnerData();
    void ImGuiKeyOwnerData_destroy(ImGuiKeyOwnerData* self);
    ImGuiKeyRoutingData* ImGuiKeyRoutingData_ImGuiKeyRoutingData();
    void ImGuiKeyRoutingData_destroy(ImGuiKeyRoutingData* self);
    void ImGuiKeyRoutingTable_Clear(ImGuiKeyRoutingTable* self);
    ImGuiKeyRoutingTable* ImGuiKeyRoutingTable_ImGuiKeyRoutingTable();
    void ImGuiKeyRoutingTable_destroy(ImGuiKeyRoutingTable* self);
    ImGuiLastItemData* ImGuiLastItemData_ImGuiLastItemData();
    void ImGuiLastItemData_destroy(ImGuiLastItemData* self);
    ImGuiListClipperData* ImGuiListClipperData_ImGuiListClipperData();
    void ImGuiListClipperData_Reset(ImGuiListClipperData* self, ImGuiListClipper* clipper);
    void ImGuiListClipperData_destroy(ImGuiListClipperData* self);
    ImGuiListClipperRange ImGuiListClipperRange_FromIndices(int min, int max);
    ImGuiListClipperRange ImGuiListClipperRange_FromPositions(float y1, float y2, int off_min, int off_max);
    void ImGuiListClipper_Begin(ImGuiListClipper* self, int items_count, float items_height = -1.0f);
    void ImGuiListClipper_End(ImGuiListClipper* self);
    ImGuiListClipper* ImGuiListClipper_ImGuiListClipper();
    void ImGuiListClipper_IncludeItemByIndex(ImGuiListClipper* self, int item_index);
    void ImGuiListClipper_IncludeItemsByIndex(ImGuiListClipper* self, int item_begin, int item_end);
    void ImGuiListClipper_SeekCursorForItem(ImGuiListClipper* self, int item_index);
    bool ImGuiListClipper_Step(ImGuiListClipper* self);
    void ImGuiListClipper_destroy(ImGuiListClipper* self);
    void ImGuiMenuColumns_CalcNextTotalWidth(ImGuiMenuColumns* self, bool update_offsets);
    float ImGuiMenuColumns_DeclColumns(ImGuiMenuColumns* self, float w_icon, float w_label, float w_shortcut, float w_mark);
    ImGuiMenuColumns* ImGuiMenuColumns_ImGuiMenuColumns();
    void ImGuiMenuColumns_Update(ImGuiMenuColumns* self, float spacing, bool window_reappearing);
    void ImGuiMenuColumns_destroy(ImGuiMenuColumns* self);
    ImGuiMultiSelectState* ImGuiMultiSelectState_ImGuiMultiSelectState();
    void ImGuiMultiSelectState_destroy(ImGuiMultiSelectState* self);
    void ImGuiMultiSelectTempData_Clear(ImGuiMultiSelectTempData* self);
    void ImGuiMultiSelectTempData_ClearIO(ImGuiMultiSelectTempData* self);
    ImGuiMultiSelectTempData* ImGuiMultiSelectTempData_ImGuiMultiSelectTempData();
    void ImGuiMultiSelectTempData_destroy(ImGuiMultiSelectTempData* self);
    void ImGuiNavItemData_Clear(ImGuiNavItemData* self);
    ImGuiNavItemData* ImGuiNavItemData_ImGuiNavItemData();
    void ImGuiNavItemData_destroy(ImGuiNavItemData* self);
    void ImGuiNextItemData_ClearFlags(ImGuiNextItemData* self);
    ImGuiNextItemData* ImGuiNextItemData_ImGuiNextItemData();
    void ImGuiNextItemData_destroy(ImGuiNextItemData* self);
    void ImGuiNextWindowData_ClearFlags(ImGuiNextWindowData* self);
    ImGuiNextWindowData* ImGuiNextWindowData_ImGuiNextWindowData();
    void ImGuiNextWindowData_destroy(ImGuiNextWindowData* self);
    ImGuiOldColumnData* ImGuiOldColumnData_ImGuiOldColumnData();
    void ImGuiOldColumnData_destroy(ImGuiOldColumnData* self);
    ImGuiOldColumns* ImGuiOldColumns_ImGuiOldColumns();
    void ImGuiOldColumns_destroy(ImGuiOldColumns* self);
    ImGuiOnceUponAFrame* ImGuiOnceUponAFrame_ImGuiOnceUponAFrame();
    void ImGuiOnceUponAFrame_destroy(ImGuiOnceUponAFrame* self);
    ImGuiPackedDate* ImGuiPackedDate_ImGuiPackedDate_Nil();
    ImGuiPackedDate* ImGuiPackedDate_ImGuiPackedDate_Int(int yyyymmdd);
    bool ImGuiPackedDate_IsValid(ImGuiPackedDate* self);
    void ImGuiPackedDate_SubtractMonths(ImGuiPackedDate* self, int m);
    int ImGuiPackedDate_Unpack(ImGuiPackedDate* self);
    void ImGuiPackedDate_destroy(ImGuiPackedDate* self);
    void ImGuiPayload_Clear(ImGuiPayload* self);
    ImGuiPayload* ImGuiPayload_ImGuiPayload();
    bool ImGuiPayload_IsDataType(ImGuiPayload* self, const(char)* type);
    bool ImGuiPayload_IsDelivery(ImGuiPayload* self);
    bool ImGuiPayload_IsPreview(ImGuiPayload* self);
    void ImGuiPayload_destroy(ImGuiPayload* self);
    void ImGuiPlatformIO_ClearPlatformHandlers(ImGuiPlatformIO* self);
    void ImGuiPlatformIO_ClearRendererHandlers(ImGuiPlatformIO* self);
    ImGuiPlatformIO* ImGuiPlatformIO_ImGuiPlatformIO();
    void ImGuiPlatformIO_destroy(ImGuiPlatformIO* self);
    ImGuiPlatformImeData* ImGuiPlatformImeData_ImGuiPlatformImeData();
    void ImGuiPlatformImeData_destroy(ImGuiPlatformImeData* self);
    ImGuiPlatformMonitor* ImGuiPlatformMonitor_ImGuiPlatformMonitor();
    void ImGuiPlatformMonitor_destroy(ImGuiPlatformMonitor* self);
    ImGuiPopupData* ImGuiPopupData_ImGuiPopupData();
    void ImGuiPopupData_destroy(ImGuiPopupData* self);
    ImGuiPtrOrIndex* ImGuiPtrOrIndex_ImGuiPtrOrIndex_Ptr(void* ptr);
    ImGuiPtrOrIndex* ImGuiPtrOrIndex_ImGuiPtrOrIndex_Int(int index);
    void ImGuiPtrOrIndex_destroy(ImGuiPtrOrIndex* self);
    void ImGuiSelectionBasicStorage_ApplyRequests(ImGuiSelectionBasicStorage* self, ImGuiMultiSelectIO* ms_io);
    void ImGuiSelectionBasicStorage_Clear(ImGuiSelectionBasicStorage* self);
    bool ImGuiSelectionBasicStorage_Contains(ImGuiSelectionBasicStorage* self, ImGuiID id);
    bool ImGuiSelectionBasicStorage_GetNextSelectedItem(ImGuiSelectionBasicStorage* self, void** opaque_it, ImGuiID* out_id);
    ImGuiID ImGuiSelectionBasicStorage_GetStorageIdFromIndex(ImGuiSelectionBasicStorage* self, int idx);
    ImGuiSelectionBasicStorage* ImGuiSelectionBasicStorage_ImGuiSelectionBasicStorage();
    void ImGuiSelectionBasicStorage_SetItemSelected(ImGuiSelectionBasicStorage* self, ImGuiID id, bool selected);
    void ImGuiSelectionBasicStorage_Swap(ImGuiSelectionBasicStorage* self, ImGuiSelectionBasicStorage* r);
    void ImGuiSelectionBasicStorage_destroy(ImGuiSelectionBasicStorage* self);
    void ImGuiSelectionExternalStorage_ApplyRequests(ImGuiSelectionExternalStorage* self, ImGuiMultiSelectIO* ms_io);
    ImGuiSelectionExternalStorage* ImGuiSelectionExternalStorage_ImGuiSelectionExternalStorage();
    void ImGuiSelectionExternalStorage_destroy(ImGuiSelectionExternalStorage* self);
    ImGuiSettingsHandler* ImGuiSettingsHandler_ImGuiSettingsHandler();
    void ImGuiSettingsHandler_destroy(ImGuiSettingsHandler* self);
    ImGuiStackLevelInfo* ImGuiStackLevelInfo_ImGuiStackLevelInfo();
    void ImGuiStackLevelInfo_destroy(ImGuiStackLevelInfo* self);
    ImGuiStoragePair* ImGuiStoragePair_ImGuiStoragePair_Int(ImGuiID _key, int _val);
    ImGuiStoragePair* ImGuiStoragePair_ImGuiStoragePair_Float(ImGuiID _key, float _val);
    ImGuiStoragePair* ImGuiStoragePair_ImGuiStoragePair_Ptr(ImGuiID _key, void* _val);
    void ImGuiStoragePair_destroy(ImGuiStoragePair* self);
    void ImGuiStorage_BuildSortByKey(ImGuiStorage* self);
    void ImGuiStorage_Clear(ImGuiStorage* self);
    bool ImGuiStorage_GetBool(ImGuiStorage* self, ImGuiID key, bool default_val = false);
    bool* ImGuiStorage_GetBoolRef(ImGuiStorage* self, ImGuiID key, bool default_val = false);
    float ImGuiStorage_GetFloat(ImGuiStorage* self, ImGuiID key, float default_val = 0.0f);
    float* ImGuiStorage_GetFloatRef(ImGuiStorage* self, ImGuiID key, float default_val = 0.0f);
    int ImGuiStorage_GetInt(ImGuiStorage* self, ImGuiID key, int default_val = 0);
    int* ImGuiStorage_GetIntRef(ImGuiStorage* self, ImGuiID key, int default_val = 0);
    void* ImGuiStorage_GetVoidPtr(ImGuiStorage* self, ImGuiID key);
    void** ImGuiStorage_GetVoidPtrRef(ImGuiStorage* self, ImGuiID key, void* default_val = null);
    void ImGuiStorage_SetAllInt(ImGuiStorage* self, int val);
    void ImGuiStorage_SetBool(ImGuiStorage* self, ImGuiID key, bool val);
    void ImGuiStorage_SetFloat(ImGuiStorage* self, ImGuiID key, float val);
    void ImGuiStorage_SetInt(ImGuiStorage* self, ImGuiID key, int val);
    void ImGuiStorage_SetVoidPtr(ImGuiStorage* self, ImGuiID key, void* val);
    ImGuiStyleMod* ImGuiStyleMod_ImGuiStyleMod_Int(ImGuiStyleVar idx, int v);
    ImGuiStyleMod* ImGuiStyleMod_ImGuiStyleMod_Float(ImGuiStyleVar idx, float v);
    ImGuiStyleMod* ImGuiStyleMod_ImGuiStyleMod_Vec2(ImGuiStyleVar idx, ImVec2 v);
    void ImGuiStyleMod_destroy(ImGuiStyleMod* self);
    void* ImGuiStyleVarInfo_GetVarPtr(ImGuiStyleVarInfo* self, void* parent);
    ImGuiStyle* ImGuiStyle_ImGuiStyle();
    void ImGuiStyle_ScaleAllSizes(ImGuiStyle* self, float scale_factor);
    void ImGuiStyle_destroy(ImGuiStyle* self);
    ImGuiTabBar* ImGuiTabBar_ImGuiTabBar();
    void ImGuiTabBar_destroy(ImGuiTabBar* self);
    ImGuiTabItem* ImGuiTabItem_ImGuiTabItem();
    void ImGuiTabItem_destroy(ImGuiTabItem* self);
    ImGuiTableColumnSettings* ImGuiTableColumnSettings_ImGuiTableColumnSettings();
    void ImGuiTableColumnSettings_destroy(ImGuiTableColumnSettings* self);
    ImGuiTableColumnSortSpecs* ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs();
    void ImGuiTableColumnSortSpecs_destroy(ImGuiTableColumnSortSpecs* self);
    ImGuiTableColumn* ImGuiTableColumn_ImGuiTableColumn();
    void ImGuiTableColumn_destroy(ImGuiTableColumn* self);
    ImGuiTableInstanceData* ImGuiTableInstanceData_ImGuiTableInstanceData();
    void ImGuiTableInstanceData_destroy(ImGuiTableInstanceData* self);
    ImGuiTableColumnSettings* ImGuiTableSettings_GetColumnSettings(ImGuiTableSettings* self);
    ImGuiTableSettings* ImGuiTableSettings_ImGuiTableSettings();
    void ImGuiTableSettings_destroy(ImGuiTableSettings* self);
    ImGuiTableSortSpecs* ImGuiTableSortSpecs_ImGuiTableSortSpecs();
    void ImGuiTableSortSpecs_destroy(ImGuiTableSortSpecs* self);
    ImGuiTableTempData* ImGuiTableTempData_ImGuiTableTempData();
    void ImGuiTableTempData_destroy(ImGuiTableTempData* self);
    ImGuiTable* ImGuiTable_ImGuiTable();
    void ImGuiTable_destroy(ImGuiTable* self);
    ImGuiTextBuffer* ImGuiTextBuffer_ImGuiTextBuffer();
    void ImGuiTextBuffer_append(ImGuiTextBuffer* self, const(char)* str, const(char)* str_end = null);
    void ImGuiTextBuffer_appendf(ImGuiTextBuffer* self,  const char* fmt, ...);
    void ImGuiTextBuffer_appendfv(ImGuiTextBuffer* self, const(char)* fmt, va_list args);
    const(char)* ImGuiTextBuffer_begin(ImGuiTextBuffer* self);
    const(char)* ImGuiTextBuffer_c_str(ImGuiTextBuffer* self);
    void ImGuiTextBuffer_clear(ImGuiTextBuffer* self);
    void ImGuiTextBuffer_destroy(ImGuiTextBuffer* self);
    bool ImGuiTextBuffer_empty(ImGuiTextBuffer* self);
    const(char)* ImGuiTextBuffer_end(ImGuiTextBuffer* self);
    void ImGuiTextBuffer_reserve(ImGuiTextBuffer* self, int capacity);
    void ImGuiTextBuffer_resize(ImGuiTextBuffer* self, int size);
    int ImGuiTextBuffer_size(ImGuiTextBuffer* self);
    void ImGuiTextFilter_Build(ImGuiTextFilter* self);
    void ImGuiTextFilter_Clear(ImGuiTextFilter* self);
    bool ImGuiTextFilter_Draw(ImGuiTextFilter* self, const(char)* label = "Filter(inc,-exc)", float width = 0.0f);
    ImGuiTextFilter* ImGuiTextFilter_ImGuiTextFilter(const(char)* default_filter = "");
    bool ImGuiTextFilter_IsActive(ImGuiTextFilter* self);
    bool ImGuiTextFilter_PassFilter(ImGuiTextFilter* self, const(char)* text, const(char)* text_end = null);
    void ImGuiTextFilter_destroy(ImGuiTextFilter* self);
    void ImGuiTextIndex_append(ImGuiTextIndex* self, const(char)* base, int old_size, int new_size);
    void ImGuiTextIndex_clear(ImGuiTextIndex* self);
    const(char)* ImGuiTextIndex_get_line_begin(ImGuiTextIndex* self, const(char)* base, int n);
    const(char)* ImGuiTextIndex_get_line_end(ImGuiTextIndex* self, const(char)* base, int n);
    int ImGuiTextIndex_size(ImGuiTextIndex* self);
    ImGuiTextRange* ImGuiTextRange_ImGuiTextRange_Nil();
    ImGuiTextRange* ImGuiTextRange_ImGuiTextRange_Str(const(char)* _b, const(char)* _e);
    void ImGuiTextRange_destroy(ImGuiTextRange* self);
    bool ImGuiTextRange_empty(ImGuiTextRange* self);
    void ImGuiTextRange_split(ImGuiTextRange* self, char separator, ImVector!(ImGuiTextRange)* outItem);
    void ImGuiTypingSelectState_Clear(ImGuiTypingSelectState* self);
    ImGuiTypingSelectState* ImGuiTypingSelectState_ImGuiTypingSelectState();
    void ImGuiTypingSelectState_destroy(ImGuiTypingSelectState* self);
    ImVec2 ImGuiViewportP_CalcWorkRectPos(ImGuiViewportP* self, const ImVec2 inset_min);
    ImVec2 ImGuiViewportP_CalcWorkRectSize(ImGuiViewportP* self, const ImVec2 inset_min, const ImVec2 inset_max);
    void ImGuiViewportP_ClearRequestFlags(ImGuiViewportP* self);
    ImRect ImGuiViewportP_GetBuildWorkRect(ImGuiViewportP* self);
    ImRect ImGuiViewportP_GetMainRect(ImGuiViewportP* self);
    ImRect ImGuiViewportP_GetWorkRect(ImGuiViewportP* self);
    ImGuiViewportP* ImGuiViewportP_ImGuiViewportP();
    void ImGuiViewportP_UpdateWorkRect(ImGuiViewportP* self);
    void ImGuiViewportP_destroy(ImGuiViewportP* self);
    ImVec2 ImGuiViewport_GetCenter(ImGuiViewport* self);
    const(char)* ImGuiViewport_GetDebugName(ImGuiViewport* self);
    ImVec2 ImGuiViewport_GetWorkCenter(ImGuiViewport* self);
    ImGuiViewport* ImGuiViewport_ImGuiViewport();
    void ImGuiViewport_destroy(ImGuiViewport* self);
    ImGuiWindowClass* ImGuiWindowClass_ImGuiWindowClass();
    void ImGuiWindowClass_destroy(ImGuiWindowClass* self);
    char* ImGuiWindowSettings_GetName(ImGuiWindowSettings* self);
    ImGuiWindowSettings* ImGuiWindowSettings_ImGuiWindowSettings();
    void ImGuiWindowSettings_destroy(ImGuiWindowSettings* self);
    ImGuiID ImGuiWindow_GetID_Str(ImGuiWindow* self, const(char)* str, const(char)* str_end = null);
    ImGuiID ImGuiWindow_GetID_Ptr(ImGuiWindow* self, const void* ptr);
    ImGuiID ImGuiWindow_GetID_Int(ImGuiWindow* self, int n);
    ImGuiID ImGuiWindow_GetIDFromPos(ImGuiWindow* self, const ImVec2 p_abs);
    ImGuiID ImGuiWindow_GetIDFromRectangle(ImGuiWindow* self, const ImRect r_abs);
    ImGuiWindow* ImGuiWindow_ImGuiWindow(ImGuiContext* context, const(char)* name);
    ImRect ImGuiWindow_MenuBarRect(ImGuiWindow* self);
    ImRect ImGuiWindow_Rect(ImGuiWindow* self);
    ImRect ImGuiWindow_TitleBarRect(ImGuiWindow* self);
    void ImGuiWindow_destroy(ImGuiWindow* self);
    void ImRect_Add_Vec2(ImRect* self, const ImVec2 p);
    void ImRect_Add_Rect(ImRect* self, const ImRect r);
    void ImRect_AddX(ImRect* self, float x);
    void ImRect_AddY(ImRect* self, float y);
    const(ImVec4)* ImRect_AsVec4(ImRect* self);
    void ImRect_ClipWith(ImRect* self, const ImRect r);
    void ImRect_ClipWithFull(ImRect* self, const ImRect r);
    bool ImRect_Contains_Vec2(ImRect* self, const ImVec2 p);
    bool ImRect_Contains_Rect(ImRect* self, const ImRect r);
    bool ImRect_ContainsWithPad(ImRect* self, const ImVec2 p, const ImVec2 pad);
    void ImRect_Expand_Float(ImRect* self, const float amount);
    void ImRect_Expand_Vec2(ImRect* self, const ImVec2 amount);
    float ImRect_GetArea(ImRect* self);
    ImVec2 ImRect_GetBL(ImRect* self);
    ImVec2 ImRect_GetBR(ImRect* self);
    ImVec2 ImRect_GetCenter(ImRect* self);
    float ImRect_GetHeight(ImRect* self);
    ImVec2 ImRect_GetSize(ImRect* self);
    ImVec2 ImRect_GetTL(ImRect* self);
    ImVec2 ImRect_GetTR(ImRect* self);
    float ImRect_GetWidth(ImRect* self);
    ImRect* ImRect_ImRect_Nil();
    ImRect* ImRect_ImRect_Vec2(const ImVec2 min, const ImVec2 max);
    ImRect* ImRect_ImRect_Vec4(const ImVec4 v);
    ImRect* ImRect_ImRect_Float(float x1, float y1, float x2, float y2);
    bool ImRect_IsInverted(ImRect* self);
    bool ImRect_Overlaps(ImRect* self, const ImRect r);
    ImVec4 ImRect_ToVec4(ImRect* self);
    void ImRect_Translate(ImRect* self, const ImVec2 d);
    void ImRect_TranslateX(ImRect* self, float dx);
    void ImRect_TranslateY(ImRect* self, float dy);
    void ImRect_destroy(ImRect* self);
    void ImTextureData_Create(ImTextureData* self, ImTextureFormat format, int w, int h);
    void ImTextureData_DestroyPixels(ImTextureData* self);
    int ImTextureData_GetPitch(ImTextureData* self);
    void* ImTextureData_GetPixels(ImTextureData* self);
    void* ImTextureData_GetPixelsAt(ImTextureData* self, int x, int y);
    int ImTextureData_GetSizeInBytes(ImTextureData* self);
    ImTextureID ImTextureData_GetTexID(ImTextureData* self);
    ImTextureRef ImTextureData_GetTexRef(ImTextureData* self);
    ImTextureData* ImTextureData_ImTextureData();
    void ImTextureData_SetStatus(ImTextureData* self, ImTextureStatus status);
    void ImTextureData_SetTexID(ImTextureData* self, ImTextureID tex_id);
    void ImTextureData_destroy(ImTextureData* self);
    ImTextureID ImTextureRef_GetTexID(ImTextureRef* self);
    ImTextureRef* ImTextureRef_ImTextureRef_Nil();
    ImTextureRef* ImTextureRef_ImTextureRef_TextureID(ImTextureID tex_id);
    void ImTextureRef_destroy(ImTextureRef* self);
    ImVec1* ImVec1_ImVec1_Nil();
    ImVec1* ImVec1_ImVec1_Float(float _x);
    void ImVec1_destroy(ImVec1* self);
    ImVec2* ImVec2_ImVec2_Nil();
    ImVec2* ImVec2_ImVec2_Float(float _x, float _y);
    void ImVec2_destroy(ImVec2* self);
    ImVec2i* ImVec2i_ImVec2i_Nil();
    ImVec2i* ImVec2i_ImVec2i_Int(int _x, int _y);
    void ImVec2i_destroy(ImVec2i* self);
    ImVec2ih* ImVec2ih_ImVec2ih_Nil();
    ImVec2ih* ImVec2ih_ImVec2ih_short(short _x, short _y);
    ImVec2ih* ImVec2ih_ImVec2ih_Vec2(const ImVec2 rhs);
    void ImVec2ih_destroy(ImVec2ih* self);
    ImVec4* ImVec4_ImVec4_Nil();
    ImVec4* ImVec4_ImVec4_Float(float _x, float _y, float _z, float _w);
    void ImVec4_destroy(ImVec4* self);
    const(ImGuiPayload)* igAcceptDragDropPayload(const(char)* type, ImGuiDragDropFlags flags = ImGuiDragDropFlags.None);
    void igActivateItemByID(ImGuiID id);
    ImGuiID igAddContextHook(ImGuiContext* ctx, const ImGuiContextHook* hook);
    void igAddDrawListToDrawDataEx(ImDrawData* draw_data, ImVector!(ImDrawList*)* out_list, ImDrawList* draw_list);
    void igAddSettingsHandler(const ImGuiSettingsHandler* handler);
    void igAlignTextToFramePadding();
    bool igArrowButton(const(char)* str_id, ImGuiDir dir);
    bool igArrowButtonEx(const(char)* str_id, ImGuiDir dir, ImVec2 size_arg, ImGuiButtonFlags flags = ImGuiButtonFlags.None);
    bool igBegin(const(char)* name, bool* p_open = null, ImGuiWindowFlags flags = ImGuiWindowFlags.None);
    bool igBeginBoxSelect(const ImRect scope_rect, ImGuiWindow* window, ImGuiID box_select_id, ImGuiMultiSelectFlags ms_flags);
    bool igBeginChild_Str(const(char)* str_id, const ImVec2 size = ImVec2(0,0), ImGuiChildFlags child_flags = ImGuiChildFlags.None, ImGuiWindowFlags window_flags = ImGuiWindowFlags.None);
    bool igBeginChild_ID(ImGuiID id, const ImVec2 size = ImVec2(0,0), ImGuiChildFlags child_flags = ImGuiChildFlags.None, ImGuiWindowFlags window_flags = ImGuiWindowFlags.None);
    bool igBeginChildEx(const(char)* name, ImGuiID id, const ImVec2 size_arg, ImGuiChildFlags child_flags, ImGuiWindowFlags window_flags);
    void igBeginColumns(const(char)* str_id, int count, ImGuiOldColumnFlags flags = ImGuiOldColumnFlags.None);
    bool igBeginCombo(const(char)* label, const(char)* preview_value, ImGuiComboFlags flags = ImGuiComboFlags.None);
    bool igBeginComboPopup(ImGuiID popup_id, const ImRect bb, ImGuiComboFlags flags);
    bool igBeginComboPreview();
    void igBeginDisabled(bool disabled = true);
    void igBeginDisabledOverrideReenable();
    void igBeginDockableDragDropSource(ImGuiWindow* window);
    void igBeginDockableDragDropTarget(ImGuiWindow* window);
    void igBeginDocked(ImGuiWindow* window, bool* p_open);
    bool igBeginDragDropSource(ImGuiDragDropFlags flags = ImGuiDragDropFlags.None);
    bool igBeginDragDropTarget();
    bool igBeginDragDropTargetCustom(const ImRect bb, ImGuiID id);
    bool igBeginDragDropTargetViewport(ImGuiViewport* viewport, const ImRect* p_bb = null);
    bool igBeginErrorTooltip();
    void igBeginGroup();
    bool igBeginItemTooltip();
    bool igBeginListBox(const(char)* label, const ImVec2 size = ImVec2(0,0));
    bool igBeginMainMenuBar();
    bool igBeginMenu(const(char)* label, bool enabled = true);
    bool igBeginMenuBar();
    bool igBeginMenuEx(const(char)* label, const(char)* icon, bool enabled = true);
    ImGuiMultiSelectIO* igBeginMultiSelect(ImGuiMultiSelectFlags flags, int selection_size = -1, int items_count = -1);
    bool igBeginPopup(const(char)* str_id, ImGuiWindowFlags flags = ImGuiWindowFlags.None);
    bool igBeginPopupContextItem(const(char)* str_id = null, ImGuiPopupFlags popup_flags = ImGuiPopupFlags.None);
    bool igBeginPopupContextVoid(const(char)* str_id = null, ImGuiPopupFlags popup_flags = ImGuiPopupFlags.None);
    bool igBeginPopupContextWindow(const(char)* str_id = null, ImGuiPopupFlags popup_flags = ImGuiPopupFlags.None);
    bool igBeginPopupEx(ImGuiID id, ImGuiWindowFlags extra_window_flags);
    bool igBeginPopupMenuEx(ImGuiID id, const(char)* label, ImGuiWindowFlags extra_window_flags);
    bool igBeginPopupModal(const(char)* name, bool* p_open = null, ImGuiWindowFlags flags = ImGuiWindowFlags.None);
    bool igBeginTabBar(const(char)* str_id, ImGuiTabBarFlags flags = ImGuiTabBarFlags.None);
    bool igBeginTabBarEx(ImGuiTabBar* tab_bar, const ImRect bb, ImGuiTabBarFlags flags);
    bool igBeginTabItem(const(char)* label, bool* p_open = null, ImGuiTabItemFlags flags = ImGuiTabItemFlags.None);
    bool igBeginTable(const(char)* str_id, int columns, ImGuiTableFlags flags = ImGuiTableFlags.None, const ImVec2 outer_size = ImVec2(0.0f,0.0f), float inner_width = 0.0f);
    bool igBeginTableEx(const(char)* name, ImGuiID id, int columns_count, ImGuiTableFlags flags = ImGuiTableFlags.None, const ImVec2 outer_size = ImVec2(0,0), float inner_width = 0.0f);
    bool igBeginTooltip();
    bool igBeginTooltipEx(ImGuiTooltipFlags tooltip_flags, ImGuiWindowFlags extra_window_flags);
    bool igBeginTooltipHidden();
    bool igBeginViewportSideBar(const(char)* name, ImGuiViewport* viewport, ImGuiDir dir, float size, ImGuiWindowFlags window_flags);
    void igBringWindowToDisplayBack(ImGuiWindow* window);
    void igBringWindowToDisplayBehind(ImGuiWindow* window, ImGuiWindow* above_window);
    void igBringWindowToDisplayFront(ImGuiWindow* window);
    void igBringWindowToFocusFront(ImGuiWindow* window);
    void igBullet();
    void igBulletText(const(char)* fmt, ...);
    void igBulletTextV(const(char)* fmt, va_list args);
    bool igButton(const(char)* label, const ImVec2 size = ImVec2(0,0));
    bool igButtonBehavior(const ImRect bb, ImGuiID id, bool* out_hovered, bool* out_held, ImGuiButtonFlags flags = ImGuiButtonFlags.None);
    bool igButtonEx(const(char)* label, const ImVec2 size_arg = ImVec2(0,0), ImGuiButtonFlags flags = ImGuiButtonFlags.None);
    void igCalcClipRectVisibleItemsY(const ImRect clip_rect, const ImVec2 pos, float items_height, int* out_visible_start, int* out_visible_end);
    ImVec2 igCalcItemSize(ImVec2 size, float default_w, float default_h);
    float igCalcItemWidth();
    ImDrawFlags igCalcRoundingFlagsForRectInRect(const ImRect r_in, const ImRect r_outer, float threshold);
    ImVec2 igCalcTextSize(const(char)* text, const(char)* text_end = null, bool hide_text_after_double_hash = false, float wrap_width = -1.0f);
    int igCalcTypematicRepeatAmount(float t0, float t1, float repeat_delay, float repeat_rate);
    ImVec2 igCalcWindowNextAutoFitSize(ImGuiWindow* window);
    float igCalcWrapWidthForPos(const ImVec2 pos, float wrap_pos_x);
    void igCallContextHooks(ImGuiContext* ctx, ImGuiContextHookType type);
    bool igCheckbox(const(char)* label, bool* v);
    bool igCheckboxFlags_IntPtr(const(char)* label, int* flags, int flags_value);
    bool igCheckboxFlags_UintPtr(const(char)* label, uint* flags, uint flags_value);
    bool igCheckboxFlags_S64Ptr(const(char)* label, ImS64* flags, ImS64 flags_value);
    bool igCheckboxFlags_U64Ptr(const(char)* label, ImU64* flags, ImU64 flags_value);
    void igCleanupIniSettings(ImGuiSettingsCleanupArgs* args);
    void igClearActiveID();
    void igClearDragDrop();
    void igClearIniSettings();
    void igClearWindowSettings(const(char)* name);
    bool igCloseButton(ImGuiID id, const ImVec2 pos);
    void igCloseCurrentPopup();
    void igClosePopupToLevel(int remaining, bool restore_focus_to_window_under_popup);
    void igClosePopupsExceptModals();
    void igClosePopupsOverWindow(ImGuiWindow* ref_window, bool restore_focus_to_window_under_popup);
    bool igCollapseButton(ImGuiID id, const ImVec2 pos, ImGuiDockNode* dock_node);
    bool igCollapsingHeader_TreeNodeFlags(const(char)* label, ImGuiTreeNodeFlags flags = ImGuiTreeNodeFlags.None);
    bool igCollapsingHeader_BoolPtr(const(char)* label, bool* p_visible, ImGuiTreeNodeFlags flags = ImGuiTreeNodeFlags.None);
    bool igColorButton(const(char)* desc_id, const ImVec4 col, ImGuiColorEditFlags flags = ImGuiColorEditFlags.None, const ImVec2 size = ImVec2(0,0));
    ImU32 igColorConvertFloat4ToU32(const ImVec4 inItem);
    void igColorConvertHSVtoRGB(float h, float s, float v, float* out_r, float* out_g, float* out_b);
    void igColorConvertRGBtoHSV(float r, float g, float b, float* out_h, float* out_s, float* out_v);
    ImVec4 igColorConvertU32ToFloat4(ImU32 inItem);
    bool igColorEdit3(const(char)* label, float[3]*/*[3]*/ col, ImGuiColorEditFlags flags = ImGuiColorEditFlags.None);
    bool igColorEdit4(const(char)* label, float[4]*/*[4]*/ col, ImGuiColorEditFlags flags = ImGuiColorEditFlags.None);
    void igColorEditOptionsPopup(const float* col, ImGuiColorEditFlags flags);
    bool igColorPicker3(const(char)* label, float[3]*/*[3]*/ col, ImGuiColorEditFlags flags = ImGuiColorEditFlags.None);
    bool igColorPicker4(const(char)* label, float[4]*/*[4]*/ col, ImGuiColorEditFlags flags = ImGuiColorEditFlags.None, const float* ref_col = null);
    void igColorPickerOptionsPopup(const float* ref_col, ImGuiColorEditFlags flags);
    void igColorTooltip(const(char)* text, const float* col, ImGuiColorEditFlags flags);
    void igColumns(int count = 1, const(char)* id = null, bool borders = true);
    bool igCombo_Str_arr(const(char)* label, int* current_item, const(char)** items, int items_count, int popup_max_height_in_items = -1);
    bool igCombo_Str(const(char)* label, int* current_item, const(char)* items_separated_by_zeros, int popup_max_height_in_items = -1);
    bool igCombo_FnStrPtr(const(char)* label, int* current_item, const(char)* function(void* user_data,int idx) getter, void* user_data, int items_count, int popup_max_height_in_items = -1);
    ImGuiKey igConvertSingleModFlagToKey(ImGuiKey key);
    ImGuiContext* igCreateContext(ImFontAtlas* shared_font_atlas = null);
    ImGuiWindowSettings* igCreateNewWindowSettings(const(char)* name);
    bool igDataTypeApplyFromText(const(char)* buf, ImGuiDataType data_type, void* p_data, const(char)* format, void* p_data_when_empty = null);
    void igDataTypeApplyOp(ImGuiDataType data_type, int op, void* output, const void* arg_1, const void* arg_2);
    bool igDataTypeClamp(ImGuiDataType data_type, void* p_data, const void* p_min, const void* p_max);
    int igDataTypeCompare(ImGuiDataType data_type, const void* arg_1, const void* arg_2);
    int igDataTypeFormatString(char* buf, int buf_size, ImGuiDataType data_type, const void* p_data, const(char)* format);
    const(ImGuiDataTypeInfo)* igDataTypeGetInfo(ImGuiDataType data_type);
    bool igDataTypeIsZero(ImGuiDataType data_type, const void* p_data);
    void igDebugAllocHook(ImGuiDebugAllocInfo* info, int frame_count, void* ptr, size_t size);
    bool igDebugBreakButton(const(char)* label, const(char)* description_of_location);
    void igDebugBreakButtonTooltip(bool keyboard_only, const(char)* description_of_location);
    void igDebugBreakClearData();
    bool igDebugCheckVersionAndDataLayout(const(char)* version_str, size_t sz_io, size_t sz_style, size_t sz_vec2, size_t sz_vec4, size_t sz_drawvert, size_t sz_drawidx);
    void igDebugDrawCursorPos(ImU32 col = 4278190335);
    void igDebugDrawItemRect(ImU32 col = 4278190335);
    void igDebugDrawLineExtents(ImU32 col = 4278190335);
    void igDebugFlashStyleColor(ImGuiCol idx);
    void igDebugHookIdInfo(ImGuiID id, ImGuiDataType data_type, const void* data_id, const void* data_id_end);
    void igDebugLocateItem(ImGuiID target_id);
    void igDebugLocateItemOnHover(ImGuiID target_id);
    void igDebugLocateItemResolveWithLastItem();
    void igDebugLog(const(char)* fmt, ...);
    void igDebugLogV(const(char)* fmt, va_list args);
    void igDebugNodeColumns(ImGuiOldColumns* columns);
    void igDebugNodeDockNode(ImGuiDockNode* node, const(char)* label);
    void igDebugNodeDrawCmdShowMeshAndBoundingBox(ImDrawList* out_draw_list, const ImDrawList* draw_list, const ImDrawCmd* draw_cmd, bool show_mesh, bool show_aabb);
    void igDebugNodeDrawList(ImGuiWindow* window, ImGuiViewportP* viewport, const ImDrawList* draw_list, const(char)* label);
    void igDebugNodeFont(ImFont* font);
    void igDebugNodeFontGlyph(ImFont* font, const(ImFontGlyph)* glyph);
    void igDebugNodeFontGlyphsForSrcMask(ImFont* font, ImFontBaked* baked, int src_mask);
    void igDebugNodeInputTextState(ImGuiInputTextState* state);
    void igDebugNodeMultiSelectState(ImGuiMultiSelectState* state);
    void igDebugNodePlatformMonitor(ImGuiPlatformMonitor* monitor, const(char)* label, int idx);
    void igDebugNodeStorage(ImGuiStorage* storage, const(char)* label);
    void igDebugNodeTabBar(ImGuiTabBar* tab_bar, const(char)* label);
    void igDebugNodeTable(ImGuiTable* table);
    void igDebugNodeTableSettings(ImGuiTableSettings* settings, ImGuiTable* table);
    void igDebugNodeTexture(ImTextureData* tex, int int_id, const ImFontAtlasRect* highlight_rect = null);
    void igDebugNodeTypingSelectState(ImGuiTypingSelectState* state);
    void igDebugNodeViewport(ImGuiViewportP* viewport);
    void igDebugNodeWindow(ImGuiWindow* window, const(char)* label);
    void igDebugNodeWindowSettings(ImGuiWindowSettings* settings);
    void igDebugNodeWindowsList(ImVector!(ImGuiWindow*)* windows, const(char)* label);
    void igDebugNodeWindowsListByBeginStackParent(ImGuiWindow** windows, int windows_size, ImGuiWindow* parent_in_begin_stack);
    void igDebugRenderKeyboardPreview(ImDrawList* draw_list);
    void igDebugRenderViewportThumbnail(ImDrawList* draw_list, ImGuiViewportP* viewport, const ImRect bb);
    void igDebugStartItemPicker();
    void igDebugTextEncoding(const(char)* text);
    void igDebugTextUnformattedWithLocateItem(const(char)* line_begin, const(char)* line_end);
    ImU64 igDebugTextureIDToU64(ImTextureID tex_id);
    void igDemoMarker(const(char)* file, int line, const(char)* section);
    void igDestroyContext(ImGuiContext* ctx = null);
    void igDestroyPlatformWindow(ImGuiViewportP* viewport);
    void igDestroyPlatformWindows();
    ImGuiID igDockBuilderAddNode(ImGuiID node_id = 0, ImGuiDockNodeFlags flags = ImGuiDockNodeFlags.None);
    void igDockBuilderCopyDockSpace(ImGuiID src_dockspace_id, ImGuiID dst_dockspace_id, ImVector!(const(char)*)* in_window_remap_pairs);
    void igDockBuilderCopyNode(ImGuiID src_node_id, ImGuiID dst_node_id, ImVector!(ImGuiID)* out_node_remap_pairs);
    void igDockBuilderCopyWindowSettings(const(char)* src_name, const(char)* dst_name);
    void igDockBuilderDockWindow(const(char)* window_name, ImGuiID node_id);
    void igDockBuilderFinish(ImGuiID node_id);
    ImGuiDockNode* igDockBuilderGetCentralNode(ImGuiID node_id);
    ImGuiDockNode* igDockBuilderGetNode(ImGuiID node_id);
    void igDockBuilderRemoveNode(ImGuiID node_id);
    void igDockBuilderRemoveNodeChildNodes(ImGuiID node_id);
    void igDockBuilderRemoveNodeDockedWindows(ImGuiID node_id, bool clear_settings_refs = true);
    void igDockBuilderSetNodePos(ImGuiID node_id, ImVec2 pos);
    void igDockBuilderSetNodeSize(ImGuiID node_id, ImVec2 size);
    ImGuiID igDockBuilderSplitNode(ImGuiID node_id, ImGuiDir split_dir, float size_ratio_for_node_at_dir, ImGuiID* out_id_at_dir, ImGuiID* out_id_at_opposite_dir);
    bool igDockContextCalcDropPosForDocking(ImGuiWindow* target, ImGuiDockNode* target_node, ImGuiWindow* payload_window, ImGuiDockNode* payload_node, ImGuiDir split_dir, bool split_outer, ImVec2* out_pos);
    void igDockContextClearNodes(ImGuiContext* ctx, ImGuiID root_id, bool clear_settings_refs);
    void igDockContextEndFrame(ImGuiContext* ctx);
    ImGuiDockNode* igDockContextFindNodeByID(ImGuiContext* ctx, ImGuiID id);
    ImGuiID igDockContextGenNodeID(ImGuiContext* ctx);
    void igDockContextInitialize(ImGuiContext* ctx);
    void igDockContextNewFrameUpdateDocking(ImGuiContext* ctx);
    void igDockContextNewFrameUpdateUndocking(ImGuiContext* ctx);
    void igDockContextProcessUndockNode(ImGuiContext* ctx, ImGuiDockNode* node);
    void igDockContextProcessUndockWindow(ImGuiContext* ctx, ImGuiWindow* window, bool clear_persistent_docking_ref = true);
    void igDockContextQueueDock(ImGuiContext* ctx, ImGuiWindow* target, ImGuiDockNode* target_node, ImGuiWindow* payload, ImGuiDir split_dir, float split_ratio, bool split_outer);
    void igDockContextQueueUndockNode(ImGuiContext* ctx, ImGuiDockNode* node);
    void igDockContextQueueUndockWindow(ImGuiContext* ctx, ImGuiWindow* window);
    void igDockContextRebuildNodes(ImGuiContext* ctx);
    void igDockContextShutdown(ImGuiContext* ctx);
    bool igDockNodeBeginAmendTabBar(ImGuiDockNode* node);
    void igDockNodeEndAmendTabBar();
    int igDockNodeGetDepth(const ImGuiDockNode* node);
    ImGuiDockNode* igDockNodeGetRootNode(ImGuiDockNode* node);
    ImGuiID igDockNodeGetWindowMenuButtonId(const ImGuiDockNode* node);
    bool igDockNodeIsInHierarchyOf(ImGuiDockNode* node, ImGuiDockNode* parent);
    void igDockNodeWindowMenuHandler_Default(ImGuiContext* ctx, ImGuiDockNode* node, ImGuiTabBar* tab_bar);
    ImGuiID igDockSpace(ImGuiID dockspace_id, const ImVec2 size = ImVec2(0,0), ImGuiDockNodeFlags flags = ImGuiDockNodeFlags.None, const ImGuiWindowClass* window_class = null);
    ImGuiID igDockSpaceOverViewport(ImGuiID dockspace_id = 0, const ImGuiViewport* viewport = null, ImGuiDockNodeFlags flags = ImGuiDockNodeFlags.None, const ImGuiWindowClass* window_class = null);
    bool igDragBehavior(ImGuiID id, ImGuiDataType data_type, void* p_v, float v_speed, const void* p_min, const void* p_max, const(char)* format, ImGuiSliderFlags flags);
    bool igDragFloat(const(char)* label, float* v, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const(char)* format = "%.3f", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igDragFloat2(const(char)* label, float[2]*/*[2]*/ v, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const(char)* format = "%.3f", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igDragFloat3(const(char)* label, float[3]*/*[3]*/ v, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const(char)* format = "%.3f", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igDragFloat4(const(char)* label, float[4]*/*[4]*/ v, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const(char)* format = "%.3f", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igDragFloatRange2(const(char)* label, float* v_current_min, float* v_current_max, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const(char)* format = "%.3f", const(char)* format_max = null, ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igDragInt(const(char)* label, int* v, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const(char)* format = "%d", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igDragInt2(const(char)* label, int[2]*/*[2]*/ v, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const(char)* format = "%d", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igDragInt3(const(char)* label, int[3]*/*[3]*/ v, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const(char)* format = "%d", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igDragInt4(const(char)* label, int[4]*/*[4]*/ v, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const(char)* format = "%d", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igDragIntRange2(const(char)* label, int* v_current_min, int* v_current_max, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const(char)* format = "%d", const(char)* format_max = null, ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igDragScalar(const(char)* label, ImGuiDataType data_type, void* p_data, float v_speed = 1.0f, const void* p_min = null, const void* p_max = null, const(char)* format = null, ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igDragScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, float v_speed = 1.0f, const void* p_min = null, const void* p_max = null, const(char)* format = null, ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    void igDummy(const ImVec2 size);
    void igEnd();
    void igEndBoxSelect(const ImRect scope_rect, ImGuiMultiSelectFlags ms_flags);
    void igEndChild();
    void igEndColumns();
    void igEndCombo();
    void igEndComboPreview();
    void igEndDisabled();
    void igEndDisabledOverrideReenable();
    void igEndDragDropSource();
    void igEndDragDropTarget();
    void igEndErrorTooltip();
    void igEndFrame();
    void igEndGroup();
    void igEndListBox();
    void igEndMainMenuBar();
    void igEndMenu();
    void igEndMenuBar();
    ImGuiMultiSelectIO* igEndMultiSelect();
    void igEndPopup();
    void igEndTabBar();
    void igEndTabItem();
    void igEndTable();
    void igEndTooltip();
    void igErrorCheckEndFrameFinalizeErrorTooltip();
    void igErrorCheckUsingSetCursorPosToExtendParentBoundaries();
    bool igErrorLog(const(char)* msg);
    void igErrorRecoveryStoreState(ImGuiErrorRecoveryState* state_out);
    void igErrorRecoveryTryToRecoverState(const ImGuiErrorRecoveryState* state_in);
    void igErrorRecoveryTryToRecoverWindowState(const ImGuiErrorRecoveryState* state_in);
    void igExtendHitBoxWhenNearViewportEdge(ImGuiWindow* window, ImRect* bb, float threshold, ImGuiAxis axis);
    ImVec2 igFindBestWindowPosForPopup(ImGuiWindow* window);
    ImVec2 igFindBestWindowPosForPopupEx(const ImVec2 ref_pos, const ImVec2 size, ImGuiDir* last_dir, const ImRect r_outer, const ImRect r_avoid, ImGuiPopupPositionPolicy policy);
    ImGuiWindow* igFindBlockingModal(ImGuiWindow* window);
    ImGuiWindow* igFindBottomMostVisibleWindowWithinBeginStack(ImGuiWindow* window);
    ImGuiWindow* igFindFrontMostVisibleChildWindow(ImGuiWindow* window);
    ImGuiViewportP* igFindHoveredViewportFromPlatformWindowStack(const ImVec2 mouse_platform_pos);
    void igFindHoveredWindowEx(const ImVec2 pos, bool find_first_and_in_any_viewport, ImGuiWindow** out_hovered_window, ImGuiWindow** out_hovered_window_under_moving_window);
    ImGuiOldColumns* igFindOrCreateColumns(ImGuiWindow* window, ImGuiID id);
    const(char)* igFindRenderedTextEnd(const(char)* text, const(char)* text_end = null);
    ImGuiSettingsHandler* igFindSettingsHandler(const(char)* type_name);
    ImGuiViewport* igFindViewportByID(ImGuiID viewport_id);
    ImGuiViewport* igFindViewportByPlatformHandle(void* platform_handle);
    ImGuiWindow* igFindWindowByID(ImGuiID id);
    ImGuiWindow* igFindWindowByName(const(char)* name);
    int igFindWindowDisplayIndex(ImGuiWindow* window);
    ImGuiWindowSettings* igFindWindowSettingsByID(ImGuiID id);
    ImGuiWindowSettings* igFindWindowSettingsByWindow(ImGuiWindow* window);
    ImGuiKeyChord igFixupKeyChord(ImGuiKeyChord key_chord);
    void igFocusItem();
    void igFocusTopMostWindowUnderOne(ImGuiWindow* under_this_window, ImGuiWindow* ignore_window, ImGuiViewport* filter_viewport, ImGuiFocusRequestFlags flags);
    void igFocusWindow(ImGuiWindow* window, ImGuiFocusRequestFlags flags = ImGuiFocusRequestFlags.None);
    void igGcAwakeTransientWindowBuffers(ImGuiWindow* window);
    void igGcCompactTransientMiscBuffers();
    void igGcCompactTransientWindowBuffers(ImGuiWindow* window);
    ImGuiID igGetActiveID();
    void igGetAllocatorFunctions(ImGuiMemAllocFunc* p_alloc_func, ImGuiMemFreeFunc* p_free_func, void** p_user_data);
    ImDrawList* igGetBackgroundDrawList(ImGuiViewport* viewport = null);
    ImGuiBoxSelectState* igGetBoxSelectState(ImGuiID id);
    const(char)* igGetClipboardText();
    ImU32 igGetColorU32_Col(ImGuiCol idx, float alpha_mul = 1.0f);
    ImU32 igGetColorU32_Vec4(const ImVec4 col);
    ImU32 igGetColorU32_U32(ImU32 col, float alpha_mul = 1.0f);
    int igGetColumnIndex();
    float igGetColumnNormFromOffset(const ImGuiOldColumns* columns, float offset);
    float igGetColumnOffset(int column_index = -1);
    float igGetColumnOffsetFromNorm(const ImGuiOldColumns* columns, float offset_norm);
    float igGetColumnWidth(int column_index = -1);
    int igGetColumnsCount();
    ImGuiID igGetColumnsID(const(char)* str_id, int count);
    ImVec2 igGetContentRegionAvail();
    ImGuiContext* igGetCurrentContext();
    ImGuiID igGetCurrentFocusScope();
    ImGuiTabBar* igGetCurrentTabBar();
    ImGuiTable* igGetCurrentTable();
    ImGuiWindow* igGetCurrentWindow();
    ImGuiWindow* igGetCurrentWindowRead();
    ImVec2 igGetCursorPos();
    float igGetCursorPosX();
    float igGetCursorPosY();
    ImVec2 igGetCursorScreenPos();
    ImVec2 igGetCursorStartPos();
    ImFont* igGetDefaultFont();
    const(ImGuiPayload)* igGetDragDropPayload();
    ImDrawData* igGetDrawData();
    ImDrawListSharedData* igGetDrawListSharedData();
    ImGuiID igGetFocusID();
    ImFont* igGetFont();
    ImFontBaked* igGetFontBaked();
    float igGetFontRasterizerDensity();
    float igGetFontSize();
    ImVec2 igGetFontTexUvWhitePixel();
    ImDrawList* igGetForegroundDrawList_ViewportPtr(ImGuiViewport* viewport = null);
    ImDrawList* igGetForegroundDrawList_WindowPtr(ImGuiWindow* window);
    int igGetFrameCount();
    float igGetFrameHeight();
    float igGetFrameHeightWithSpacing();
    ImGuiID igGetHoveredID();
    ImGuiID igGetID_Str(const(char)* str_id);
    ImGuiID igGetID_StrStr(const(char)* str_id_begin, const(char)* str_id_end);
    ImGuiID igGetID_Ptr(const void* ptr_id);
    ImGuiID igGetID_Int(int int_id);
    ImGuiID igGetIDWithSeed_Str(const(char)* str_id_begin, const(char)* str_id_end, ImGuiID seed);
    ImGuiID igGetIDWithSeed_Int(int n, ImGuiID seed);
    ImGuiIO* igGetIO_Nil();
    ImGuiIO* igGetIO_ContextPtr(ImGuiContext* ctx);
    ImGuiInputTextState* igGetInputTextState(ImGuiID id);
    int igGetItemClickedCountWithSingleClickDelay(ImGuiMouseButton mouse_button = ImGuiMouseButton.Left, float delay = -1.0f);
    ImGuiItemFlags igGetItemFlags();
    ImGuiID igGetItemID();
    ImVec2 igGetItemRectMax();
    ImVec2 igGetItemRectMin();
    ImVec2 igGetItemRectSize();
    ImGuiItemStatusFlags igGetItemStatusFlags();
    const(char)* igGetKeyChordName(ImGuiKeyChord key_chord);
    ImGuiKeyData* igGetKeyData_ContextPtr(ImGuiContext* ctx, ImGuiKey key);
    ImGuiKeyData* igGetKeyData_Key(ImGuiKey key);
    ImVec2 igGetKeyMagnitude2d(ImGuiKey key_left, ImGuiKey key_right, ImGuiKey key_up, ImGuiKey key_down);
    const(char)* igGetKeyName(ImGuiKey key);
    ImGuiID igGetKeyOwner(ImGuiKey key);
    ImGuiKeyOwnerData* igGetKeyOwnerData(ImGuiContext* ctx, ImGuiKey key);
    int igGetKeyPressedAmount(ImGuiKey key, float repeat_delay, float rate);
    ImGuiViewport* igGetMainViewport();
    ImGuiMouseButton igGetMouseButtonFromPopupFlags(ImGuiPopupFlags flags);
    int igGetMouseClickedCount(ImGuiMouseButton button);
    ImGuiMouseCursor igGetMouseCursor();
    ImVec2 igGetMouseDragDelta(ImGuiMouseButton button = ImGuiMouseButton.Left, float lock_threshold = -1.0f);
    ImVec2 igGetMousePos();
    ImVec2 igGetMousePosOnOpeningCurrentPopup();
    ImGuiMultiSelectState* igGetMultiSelectState(ImGuiID id);
    float igGetNavTweakPressedAmount(ImGuiAxis axis);
    ImGuiPlatformIO* igGetPlatformIO_Nil();
    ImGuiPlatformIO* igGetPlatformIO_ContextPtr(ImGuiContext* ctx);
    ImRect igGetPopupAllowedExtentRect(ImGuiWindow* window);
    float igGetRoundedFontSize(float size);
    float igGetScale();
    float igGetScrollMaxX();
    float igGetScrollMaxY();
    float igGetScrollX();
    float igGetScrollY();
    ImGuiKeyRoutingData* igGetShortcutRoutingData(ImGuiKeyChord key_chord);
    ImGuiStorage* igGetStateStorage();
    ImGuiStyle* igGetStyle();
    const(char)* igGetStyleColorName(ImGuiCol idx);
    const(ImVec4)* igGetStyleColorVec4(ImGuiCol idx);
    const(ImGuiStyleVarInfo)* igGetStyleVarInfo(ImGuiStyleVar idx);
    float igGetTextLineHeight();
    float igGetTextLineHeightWithSpacing();
    double igGetTime();
    ImGuiWindow* igGetTopMostAndVisiblePopupModal();
    ImGuiWindow* igGetTopMostPopupModal();
    float igGetTreeNodeToLabelSpacing();
    void igGetTypematicRepeatRate(ImGuiInputFlags flags, float* repeat_delay, float* repeat_rate);
    ImGuiTypingSelectRequest* igGetTypingSelectRequest(ImGuiTypingSelectFlags flags = ImGuiTypingSelectFlags.None);
    const(char)* igGetVersion();
    const(ImGuiPlatformMonitor)* igGetViewportPlatformMonitor(ImGuiViewport* viewport);
    bool igGetWindowAlwaysWantOwnTabBar(ImGuiWindow* window);
    ImGuiID igGetWindowDockID();
    ImGuiDockNode* igGetWindowDockNode();
    float igGetWindowDpiScale();
    ImDrawList* igGetWindowDrawList();
    float igGetWindowHeight();
    ImVec2 igGetWindowPos();
    ImGuiID igGetWindowResizeBorderID(ImGuiWindow* window, ImGuiDir dir);
    ImGuiID igGetWindowResizeCornerID(ImGuiWindow* window, int n);
    ImGuiID igGetWindowScrollbarID(ImGuiWindow* window, ImGuiAxis axis);
    ImRect igGetWindowScrollbarRect(ImGuiWindow* window, ImGuiAxis axis);
    ImVec2 igGetWindowSize();
    ImGuiViewport* igGetWindowViewport();
    float igGetWindowWidth();
    int igImAbs_Int(int x);
    float igImAbs_Float(float x);
    double igImAbs_double(double x);
    ImU32 igImAlphaBlendColors(ImU32 col_a, ImU32 col_b);
    ImVec2 igImBezierCubicCalc(const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, const ImVec2 p4, float t);
    ImVec2 igImBezierCubicClosestPoint(const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, const ImVec2 p4, const ImVec2 p, int num_segments);
    ImVec2 igImBezierCubicClosestPointCasteljau(const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, const ImVec2 p4, const ImVec2 p, float tess_tol);
    ImVec2 igImBezierQuadraticCalc(const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, float t);
    void igImBitArrayClearAllBits(ImU32* arr, int bitcount);
    void igImBitArrayClearBit(ImU32* arr, int n);
    size_t igImBitArrayGetStorageSizeInBytes(int bitcount);
    void igImBitArraySetBit(ImU32* arr, int n);
    void igImBitArraySetBitRange(ImU32* arr, int n, int n2);
    bool igImBitArrayTestBit(const ImU32* arr, int n);
    float igImCeilFast(float f);
    bool igImCharIsBlankA(char c);
    bool igImCharIsBlankW(uint c);
    bool igImCharIsXdigitA(char c);
    ImVec2 igImClamp(const ImVec2 v, const ImVec2 mn, const ImVec2 mx);
    uint igImCountSetBits(uint v);
    float igImDot(const ImVec2 a, const ImVec2 b);
    float igImExponentialMovingAverage(float avg, float sample, int n);
    bool igImFileClose(ImFileHandle file);
    ImU64 igImFileGetSize(ImFileHandle file);
    void* igImFileLoadToMemory(const(char)* filename, const(char)* mode, size_t* out_file_size = null, int padding_bytes = 0);
    ImFileHandle igImFileOpen(const(char)* filename, const(char)* mode);
    ImU64 igImFileRead(void* data, ImU64 size, ImU64 count, ImFileHandle file);
    ImU64 igImFileWrite(const void* data, ImU64 size, ImU64 count, ImFileHandle file);
    float igImFloor_Float(float f);
    ImVec2 igImFloor_Vec2(const ImVec2 v);
    void igImFontAtlasAddDrawListSharedData(ImFontAtlas* atlas, ImDrawListSharedData* data);
    ImFontBaked* igImFontAtlasBakedAdd(ImFontAtlas* atlas, ImFont* font, float font_size, float font_rasterizer_density, ImGuiID baked_id);
    ImFontGlyph* igImFontAtlasBakedAddFontGlyph(ImFontAtlas* atlas, ImFontBaked* baked, ImFontConfig* src, const(ImFontGlyph)* in_glyph);
    void igImFontAtlasBakedAddFontGlyphAdvancedX(ImFontAtlas* atlas, ImFontBaked* baked, ImFontConfig* src, ImWchar codepoint, float advance_x);
    void igImFontAtlasBakedDiscard(ImFontAtlas* atlas, ImFont* font, ImFontBaked* baked);
    void igImFontAtlasBakedDiscardFontGlyph(ImFontAtlas* atlas, ImFont* font, ImFontBaked* baked, ImFontGlyph* glyph);
    ImFontBaked* igImFontAtlasBakedGetClosestMatch(ImFontAtlas* atlas, ImFont* font, float font_size, float font_rasterizer_density);
    ImGuiID igImFontAtlasBakedGetId(ImGuiID font_id, float baked_size, float rasterizer_density);
    ImFontBaked* igImFontAtlasBakedGetOrAdd(ImFontAtlas* atlas, ImFont* font, float font_size, float font_rasterizer_density);
    void igImFontAtlasBakedSetFontGlyphBitmap(ImFontAtlas* atlas, ImFontBaked* baked, ImFontConfig* src, ImFontGlyph* glyph, ImTextureRect* r, const(char)* src_pixels, ImTextureFormat src_fmt, int src_pitch);
    void igImFontAtlasBuildClear(ImFontAtlas* atlas);
    void igImFontAtlasBuildDestroy(ImFontAtlas* atlas);
    void igImFontAtlasBuildDiscardBakes(ImFontAtlas* atlas, int unused_frames);
    void igImFontAtlasBuildGetOversampleFactors(ImFontConfig* src, ImFontBaked* baked, int* out_oversample_h, int* out_oversample_v);
    void igImFontAtlasBuildInit(ImFontAtlas* atlas);
    void igImFontAtlasBuildLegacyPreloadAllGlyphRanges(ImFontAtlas* atlas);
    void igImFontAtlasBuildMain(ImFontAtlas* atlas);
    void igImFontAtlasBuildNotifySetFont(ImFontAtlas* atlas, ImFont* old_font, ImFont* new_font);
    void igImFontAtlasBuildRenderBitmapFromString(ImFontAtlas* atlas, int x, int y, int w, int h, const(char)* in_str, char in_marker_char);
    void igImFontAtlasBuildSetupFontLoader(ImFontAtlas* atlas, const(ImFontLoader)* font_loader);
    void igImFontAtlasBuildSetupFontSpecialGlyphs(ImFontAtlas* atlas, ImFont* font, ImFontConfig* src);
    void igImFontAtlasBuildUpdatePointers(ImFontAtlas* atlas);
    void igImFontAtlasDebugLogTextureRequests(ImFontAtlas* atlas);
    void igImFontAtlasFontDestroyOutput(ImFontAtlas* atlas, ImFont* font);
    void igImFontAtlasFontDestroySourceData(ImFontAtlas* atlas, ImFontConfig* src);
    void igImFontAtlasFontDiscardBakes(ImFontAtlas* atlas, ImFont* font, int unused_frames);
    bool igImFontAtlasFontInitOutput(ImFontAtlas* atlas, ImFont* font);
    void igImFontAtlasFontRebuildOutput(ImFontAtlas* atlas, ImFont* font);
    void igImFontAtlasFontSourceAddToFont(ImFontAtlas* atlas, ImFont* font, ImFontConfig* src);
    bool igImFontAtlasFontSourceInit(ImFontAtlas* atlas, ImFontConfig* src);
    const(ImFontLoader)* igImFontAtlasGetFontLoaderForStbTruetype();
    bool igImFontAtlasGetMouseCursorTexData(ImFontAtlas* atlas, ImGuiMouseCursor cursor_type, ImVec2* out_offset, ImVec2* out_size, ImVec2[2]*/*[2]*/ out_uv_border, ImVec2[2]*/*[2]*/ out_uv_fill);
    ImFontAtlasRectId igImFontAtlasPackAddRect(ImFontAtlas* atlas, int w, int h, ImFontAtlasRectEntry* overwrite_entry = null);
    void igImFontAtlasPackDiscardRect(ImFontAtlas* atlas, ImFontAtlasRectId id);
    ImTextureRect* igImFontAtlasPackGetRect(ImFontAtlas* atlas, ImFontAtlasRectId id);
    ImTextureRect* igImFontAtlasPackGetRectSafe(ImFontAtlas* atlas, ImFontAtlasRectId id);
    void igImFontAtlasPackInit(ImFontAtlas* atlas);
    uint igImFontAtlasRectId_GetGeneration(ImFontAtlasRectId id);
    int igImFontAtlasRectId_GetIndex(ImFontAtlasRectId id);
    ImFontAtlasRectId igImFontAtlasRectId_Make(int index_idx, int gen_idx);
    void igImFontAtlasRemoveDrawListSharedData(ImFontAtlas* atlas, ImDrawListSharedData* data);
    ImTextureData* igImFontAtlasTextureAdd(ImFontAtlas* atlas, int w, int h);
    void igImFontAtlasTextureBlockConvert(const(char)* src_pixels, ImTextureFormat src_fmt, int src_pitch, char* dst_pixels, ImTextureFormat dst_fmt, int dst_pitch, int w, int h);
    void igImFontAtlasTextureBlockCopy(ImTextureData* src_tex, int src_x, int src_y, ImTextureData* dst_tex, int dst_x, int dst_y, int w, int h);
    void igImFontAtlasTextureBlockFill(ImTextureData* dst_tex, int dst_x, int dst_y, int w, int h, ImU32 col);
    void igImFontAtlasTextureBlockPostProcess(ImFontAtlasPostProcessData* data);
    void igImFontAtlasTextureBlockPostProcessMultiply(ImFontAtlasPostProcessData* data, float multiply_factor);
    void igImFontAtlasTextureBlockQueueUpload(ImFontAtlas* atlas, ImTextureData* tex, int x, int y, int w, int h);
    void igImFontAtlasTextureCompact(ImFontAtlas* atlas);
    ImVec2i igImFontAtlasTextureGetSizeEstimate(ImFontAtlas* atlas);
    void igImFontAtlasTextureGrow(ImFontAtlas* atlas, int old_w = -1, int old_h = -1);
    void igImFontAtlasTextureMakeSpace(ImFontAtlas* atlas);
    void igImFontAtlasTextureRepack(ImFontAtlas* atlas, int w, int h);
    void igImFontAtlasUpdateDrawListsSharedData(ImFontAtlas* atlas);
    void igImFontAtlasUpdateDrawListsTextures(ImFontAtlas* atlas, ImTextureRef old_tex, ImTextureRef new_tex);
    void igImFontAtlasUpdateNewFrame(ImFontAtlas* atlas, int frame_count, bool renderer_has_textures);
    ImVec2 igImFontCalcTextSizeEx(ImFont* font, float size, float max_width, float wrap_width, const(char)* text_begin, const(char)* text_end_display, const(char)* text_end, const char** out_remaining, ImVec2* out_offset, ImDrawTextFlags flags);
    const(char)* igImFontCalcWordWrapPositionEx(ImFont* font, float size, const(char)* text, const(char)* text_end, float wrap_width, ImDrawTextFlags flags = ImDrawTextFlags.None);
    int igImFormatString(char* buf, size_t buf_size, const(char)* fmt, ...);
    void igImFormatStringToTempBuffer(const char** out_buf, const char** out_buf_end, const(char)* fmt, ...);
    void igImFormatStringToTempBufferV(const char** out_buf, const char** out_buf_end, const(char)* fmt, va_list args);
    int igImFormatStringV(char* buf, size_t buf_size, const(char)* fmt, va_list args);
    ImGuiID igImHashData(const void* data, size_t data_size, ImGuiID seed = 0);
    const(char)* igImHashSkipUncontributingPrefix(const(char)* label);
    ImGuiID igImHashStr(const(char)* data, size_t data_size = 0, ImGuiID seed = 0);
    float igImInvLength(const ImVec2 lhs, float fail_value);
    bool igImIsFloatAboveGuaranteedIntegerPrecision(float f);
    bool igImIsPowerOfTwo_Int(int v);
    bool igImIsPowerOfTwo_U64(ImU64 v);
    float igImLengthSqr_Vec2(const ImVec2 lhs);
    float igImLengthSqr_Vec4(const ImVec4 lhs);
    ImVec2 igImLerp_Vec2Float(const ImVec2 a, const ImVec2 b, float t);
    ImVec2 igImLerp_Vec2Vec2(const ImVec2 a, const ImVec2 b, const ImVec2 t);
    ImVec4 igImLerp_Vec4(const ImVec4 a, const ImVec4 b, float t);
    ImVec2 igImLineClosestPoint(const ImVec2 a, const ImVec2 b, const ImVec2 p);
    float igImLinearRemapClamp(float s0, float s1, float d0, float d1, float x);
    float igImLinearSweep(float current, float target, float speed);
    float igImLog_Float(float x);
    double igImLog_double(double x);
    ImGuiStoragePair* igImLowerBound(ImGuiStoragePair* in_begin, ImGuiStoragePair* in_end, ImGuiID key);
    ImVec2 igImMax(const ImVec2 lhs, const ImVec2 rhs);
    void* igImMemdup(const void* src, size_t size);
    ImVec2 igImMin(const ImVec2 lhs, const ImVec2 rhs);
    int igImModPositive(int a, int b);
    ImVec2 igImMul(const ImVec2 lhs, const ImVec2 rhs);
    const(char)* igImParseFormatFindEnd(const(char)* format);
    const(char)* igImParseFormatFindStart(const(char)* format);
    int igImParseFormatPrecision(const(char)* format, int default_value);
    void igImParseFormatSanitizeForPrinting(const(char)* fmt_in, char* fmt_out, size_t fmt_out_size);
    const(char)* igImParseFormatSanitizeForScanning(const(char)* fmt_in, char* fmt_out, size_t fmt_out_size);
    const(char)* igImParseFormatTrimDecorations(const(char)* format, char* buf, size_t buf_size);
    float igImPow_Float(float x, float y);
    double igImPow_double(double x, double y);
    ImVec2 igImRotate(const ImVec2 v, float cos_a, float sin_a);
    float igImRound64(float f);
    float igImRsqrt_Float(float x);
    double igImRsqrt_double(double x);
    float igImSaturate(float f);
    float igImSign_Float(float x);
    double igImSign_double(double x);
    const(char)* igImStrSkipBlank(const(char)* str);
    void igImStrTrimBlanks(char* str);
    const(char)* igImStrbol(const(char)* buf_mid_line, const(char)* buf_begin);
    const(char)* igImStrchrRange(const(char)* str_begin, const(char)* str_end, char c);
    char* igImStrdup(const(char)* str);
    char* igImStrdupcpy(char* dst, size_t* p_dst_size, const(char)* str);
    const(char)* igImStreolRange(const(char)* str, const(char)* str_end);
    int igImStricmp(const(char)* str1, const(char)* str2);
    const(char)* igImStristr(const(char)* haystack, const(char)* haystack_end, const(char)* needle, const(char)* needle_end);
    int igImStrlenW(const(ImWchar)* str);
    void igImStrncpy(char* dst, const(char)* src, size_t count);
    int igImStrnicmp(const(char)* str1, const(char)* str2, size_t count);
    const(char)* igImTextCalcWordWrapNextLineStart(const(char)* text, const(char)* text_end, ImDrawTextFlags flags = ImDrawTextFlags.None);
    int igImTextCharFromUtf8(uint* out_char, const(char)* in_text, const(char)* in_text_end);
    int igImTextCharToUtf8(char[5]*/*[5]*/ out_buf, uint c);
    void igImTextClassifierClear(ImU32* bits, uint codepoint_min, uint codepoint_end, ImWcharClass char_class);
    void igImTextClassifierSetCharClass(ImU32* bits, uint codepoint_min, uint codepoint_end, ImWcharClass char_class, uint c);
    void igImTextClassifierSetCharClassFromStr(ImU32* bits, uint codepoint_min, uint codepoint_end, ImWcharClass char_class, const(char)* s);
    int igImTextCountCharsFromUtf8(const(char)* in_text, const(char)* in_text_end);
    int igImTextCountLines(const(char)* in_text, const(char)* in_text_end);
    int igImTextCountUtf8BytesFromChar(const(char)* in_text, const(char)* in_text_end);
    int igImTextCountUtf8BytesFromStr(const(ImWchar)* in_text, const(ImWchar)* in_text_end);
    const(char)* igImTextFindPreviousUtf8Codepoint(const(char)* in_text_start, const(char)* in_p);
    const(char)* igImTextFindValidUtf8CodepointEnd(const(char)* in_text_start, const(char)* in_text_end, const(char)* in_p);
    void igImTextInitClassifiers();
    int igImTextStrFromUtf8(ImWchar* out_buf, int out_buf_size, const(char)* in_text, const(char)* in_text_end, const char** in_remaining = null);
    int igImTextStrToUtf8(char* out_buf, int out_buf_size, const(ImWchar)* in_text, const(ImWchar)* in_text_end);
    int igImTextureDataGetFormatBytesPerPixel(ImTextureFormat format);
    const(char)* igImTextureDataGetFormatName(ImTextureFormat format);
    const(char)* igImTextureDataGetStatusName(ImTextureStatus status);
    void igImTextureDataQueueUpload(ImTextureData* tex, int x, int y, int w, int h);
    bool igImTextureDataUpdateNewFrame(ImTextureData* tex);
    char igImToUpper(char c);
    float igImTriangleArea(const ImVec2 a, const ImVec2 b, const ImVec2 c);
    void igImTriangleBarycentricCoords(const ImVec2 a, const ImVec2 b, const ImVec2 c, const ImVec2 p, float* out_u, float* out_v, float* out_w);
    ImVec2 igImTriangleClosestPoint(const ImVec2 a, const ImVec2 b, const ImVec2 c, const ImVec2 p);
    bool igImTriangleContainsPoint(const ImVec2 a, const ImVec2 b, const ImVec2 c, const ImVec2 p);
    bool igImTriangleIsClockwise(const ImVec2 a, const ImVec2 b, const ImVec2 c);
    float igImTrunc_Float(float f);
    ImVec2 igImTrunc_Vec2(const ImVec2 v);
    float igImTrunc64(float f);
    int igImUpperPowerOfTwo(int v);
    void igImage(ImTextureRef tex_ref, const ImVec2 image_size, const ImVec2 uv0 = ImVec2(0,0), const ImVec2 uv1 = ImVec2(1,1));
    bool igImageButton(const(char)* str_id, ImTextureRef tex_ref, const ImVec2 image_size, const ImVec2 uv0 = ImVec2(0,0), const ImVec2 uv1 = ImVec2(1,1), const ImVec4 bg_col = ImVec4(0,0,0,0), const ImVec4 tint_col = ImVec4(1,1,1,1));
    bool igImageButtonEx(ImGuiID id, ImTextureRef tex_ref, const ImVec2 image_size, const ImVec2 uv0, const ImVec2 uv1, const ImVec4 bg_col, const ImVec4 tint_col, ImGuiButtonFlags flags = ImGuiButtonFlags.None);
    void igImageWithBg(ImTextureRef tex_ref, const ImVec2 image_size, const ImVec2 uv0 = ImVec2(0,0), const ImVec2 uv1 = ImVec2(1,1), const ImVec4 bg_col = ImVec4(0,0,0,0), const ImVec4 tint_col = ImVec4(1,1,1,1));
    void igIndent(float indent_w = 0.0f);
    void igInitialize();
    bool igInputDouble(const(char)* label, double* v, double step = 0.0, double step_fast = 0.0, const(char)* format = "%.6f", ImGuiInputTextFlags flags = ImGuiInputTextFlags.None);
    bool igInputFloat(const(char)* label, float* v, float step = 0.0f, float step_fast = 0.0f, const(char)* format = "%.3f", ImGuiInputTextFlags flags = ImGuiInputTextFlags.None);
    bool igInputFloat2(const(char)* label, float[2]*/*[2]*/ v, const(char)* format = "%.3f", ImGuiInputTextFlags flags = ImGuiInputTextFlags.None);
    bool igInputFloat3(const(char)* label, float[3]*/*[3]*/ v, const(char)* format = "%.3f", ImGuiInputTextFlags flags = ImGuiInputTextFlags.None);
    bool igInputFloat4(const(char)* label, float[4]*/*[4]*/ v, const(char)* format = "%.3f", ImGuiInputTextFlags flags = ImGuiInputTextFlags.None);
    bool igInputInt(const(char)* label, int* v, int step = 1, int step_fast = 100, ImGuiInputTextFlags flags = ImGuiInputTextFlags.None);
    bool igInputInt2(const(char)* label, int[2]*/*[2]*/ v, ImGuiInputTextFlags flags = ImGuiInputTextFlags.None);
    bool igInputInt3(const(char)* label, int[3]*/*[3]*/ v, ImGuiInputTextFlags flags = ImGuiInputTextFlags.None);
    bool igInputInt4(const(char)* label, int[4]*/*[4]*/ v, ImGuiInputTextFlags flags = ImGuiInputTextFlags.None);
    bool igInputScalar(const(char)* label, ImGuiDataType data_type, void* p_data, const void* p_step = null, const void* p_step_fast = null, const(char)* format = null, ImGuiInputTextFlags flags = ImGuiInputTextFlags.None);
    bool igInputScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, const void* p_step = null, const void* p_step_fast = null, const(char)* format = null, ImGuiInputTextFlags flags = ImGuiInputTextFlags.None);
    bool igInputText(const(char)* label, char* buf, size_t buf_size, ImGuiInputTextFlags flags = ImGuiInputTextFlags.None, ImGuiInputTextCallback callback = null, void* user_data = null);
    void igInputTextDeactivateHook(ImGuiID id);
    bool igInputTextEx(const(char)* label, const(char)* hint, char* buf, int buf_size, const ImVec2 size_arg, ImGuiInputTextFlags flags, ImGuiInputTextCallback callback = null, void* user_data = null);
    bool igInputTextMultiline(const(char)* label, char* buf, size_t buf_size, const ImVec2 size = ImVec2(0,0), ImGuiInputTextFlags flags = ImGuiInputTextFlags.None, ImGuiInputTextCallback callback = null, void* user_data = null);
    bool igInputTextWithHint(const(char)* label, const(char)* hint, char* buf, size_t buf_size, ImGuiInputTextFlags flags = ImGuiInputTextFlags.None, ImGuiInputTextCallback callback = null, void* user_data = null);
    bool igInvisibleButton(const(char)* str_id, const ImVec2 size, ImGuiButtonFlags flags = ImGuiButtonFlags.None);
    bool igIsActiveIdUsingNavDir(ImGuiDir dir);
    bool igIsAliasKey(ImGuiKey key);
    bool igIsAnyItemActive();
    bool igIsAnyItemFocused();
    bool igIsAnyItemHovered();
    bool igIsAnyMouseDown();
    bool igIsClippedEx(const ImRect bb, ImGuiID id);
    bool igIsDragDropActive();
    bool igIsDragDropPayloadBeingAccepted();
    bool igIsGamepadKey(ImGuiKey key);
    bool igIsInNavFocusRoute(ImGuiID focus_scope_id);
    bool igIsItemActivated();
    bool igIsItemActive();
    bool igIsItemActiveAsInputText();
    bool igIsItemClicked(ImGuiMouseButton mouse_button = ImGuiMouseButton.Left);
    bool igIsItemDeactivated();
    bool igIsItemDeactivatedAfterEdit();
    bool igIsItemEdited();
    bool igIsItemFocused();
    bool igIsItemHovered(ImGuiHoveredFlags flags = ImGuiHoveredFlags.None);
    bool igIsItemToggledOpen();
    bool igIsItemToggledSelection();
    bool igIsItemVisible();
    bool igIsKeyChordPressed_Nil(ImGuiKeyChord key_chord);
    bool igIsKeyChordPressed_InputFlags(ImGuiKeyChord key_chord, ImGuiInputFlags flags, ImGuiID owner_id = 0);
    bool igIsKeyDown_Nil(ImGuiKey key);
    bool igIsKeyDown_ID(ImGuiKey key, ImGuiID owner_id);
    bool igIsKeyPressed_Bool(ImGuiKey key, bool repeat = true);
    bool igIsKeyPressed_InputFlags(ImGuiKey key, ImGuiInputFlags flags, ImGuiID owner_id = 0);
    bool igIsKeyReleased_Nil(ImGuiKey key);
    bool igIsKeyReleased_ID(ImGuiKey key, ImGuiID owner_id);
    bool igIsKeyboardKey(ImGuiKey key);
    bool igIsLRModKey(ImGuiKey key);
    bool igIsLegacyKey(ImGuiKey key);
    bool igIsMouseClicked_Bool(ImGuiMouseButton button, bool repeat = false);
    bool igIsMouseClicked_InputFlags(ImGuiMouseButton button, ImGuiInputFlags flags, ImGuiID owner_id = 0);
    bool igIsMouseDoubleClicked_Nil(ImGuiMouseButton button);
    bool igIsMouseDoubleClicked_ID(ImGuiMouseButton button, ImGuiID owner_id);
    bool igIsMouseDown_Nil(ImGuiMouseButton button);
    bool igIsMouseDown_ID(ImGuiMouseButton button, ImGuiID owner_id);
    bool igIsMouseDragPastThreshold(ImGuiMouseButton button, float lock_threshold = -1.0f);
    bool igIsMouseDragging(ImGuiMouseButton button, float lock_threshold = -1.0f);
    bool igIsMouseHoveringRect(const ImVec2 r_min, const ImVec2 r_max, bool clip = true);
    bool igIsMouseKey(ImGuiKey key);
    bool igIsMousePosValid(const ImVec2* mouse_pos = null);
    bool igIsMouseReleased_Nil(ImGuiMouseButton button);
    bool igIsMouseReleased_ID(ImGuiMouseButton button, ImGuiID owner_id);
    bool igIsMouseReleasedWithDelay(ImGuiMouseButton button, float delay = -1.0f);
    bool igIsNamedKey(ImGuiKey key);
    bool igIsNamedKeyOrMod(ImGuiKey key);
    bool igIsPopupOpen_Str(const(char)* str_id, ImGuiPopupFlags flags = ImGuiPopupFlags.None);
    bool igIsPopupOpen_ID(ImGuiID id, ImGuiPopupFlags popup_flags);
    bool igIsPopupOpenRequestForItem(ImGuiPopupFlags flags, ImGuiID id);
    bool igIsPopupOpenRequestForWindow(ImGuiPopupFlags flags);
    bool igIsRectVisible_Nil(const ImVec2 size);
    bool igIsRectVisible_Vec2(const ImVec2 rect_min, const ImVec2 rect_max);
    bool igIsWindowAbove(ImGuiWindow* potential_above, ImGuiWindow* potential_below);
    bool igIsWindowAppearing();
    bool igIsWindowChildOf(ImGuiWindow* window, ImGuiWindow* potential_parent, bool popup_hierarchy, bool dock_hierarchy);
    bool igIsWindowCollapsed();
    bool igIsWindowContentHoverable(ImGuiWindow* window, ImGuiHoveredFlags flags = ImGuiHoveredFlags.None);
    bool igIsWindowDocked();
    bool igIsWindowFocused(ImGuiFocusedFlags flags = ImGuiFocusedFlags.None);
    bool igIsWindowHovered(ImGuiHoveredFlags flags = ImGuiHoveredFlags.None);
    bool igIsWindowInBeginStack(ImGuiWindow* window);
    bool igIsWindowNavFocusable(ImGuiWindow* window);
    bool igIsWindowWithinBeginStackOf(ImGuiWindow* window, ImGuiWindow* potential_parent);
    bool igItemAdd(const ImRect bb, ImGuiID id, const ImRect* nav_bb = null, ImGuiItemFlags extra_flags = ImGuiItemFlags.None);
    bool igItemHoverable(const ImRect bb, ImGuiID id, ImGuiItemFlags item_flags);
    void igItemSize_Vec2(const ImVec2 size, float text_baseline_y = -1.0f);
    void igItemSize_Rect(const ImRect bb, float text_baseline_y = -1.0f);
    void igKeepAliveID(ImGuiID id);
    void igLabelText(const(char)* label, const(char)* fmt, ...);
    void igLabelTextV(const(char)* label, const(char)* fmt, va_list args);
    bool igListBox_Str_arr(const(char)* label, int* current_item, const(char)** items, int items_count, int height_in_items = -1);
    bool igListBox_FnStrPtr(const(char)* label, int* current_item, const(char)* function(void* user_data,int idx) getter, void* user_data, int items_count, int height_in_items = -1);
    void igLoadIniSettingsFromDisk(const(char)* ini_filename);
    void igLoadIniSettingsFromMemory(const(char)* ini_data, size_t ini_size = 0);
    const(char)* igLocalizeGetMsg(ImGuiLocKey key);
    void igLocalizeRegisterEntries(const ImGuiLocEntry* entries, int count);
    void igLogBegin(ImGuiLogFlags flags, int auto_open_depth);
    void igLogButtons();
    void igLogFinish();
    void igLogRenderedText(const ImVec2* ref_pos, const(char)* text, const(char)* text_end = null);
    void igLogSetNextTextDecoration(const(char)* prefix, const(char)* suffix);
    void igLogText(const(char)* fmt, ...);
    void igLogTextV(const(char)* fmt, va_list args);
    void igLogToBuffer(int auto_open_depth = -1);
    void igLogToClipboard(int auto_open_depth = -1);
    void igLogToFile(int auto_open_depth = -1, const(char)* filename = null);
    void igLogToTTY(int auto_open_depth = -1);
    void igMarkIniSettingsDirty_Nil();
    void igMarkIniSettingsDirty_WindowPtr(ImGuiWindow* window);
    void igMarkItemEdited(ImGuiID id);
    void* igMemAlloc(size_t size);
    void igMemFree(void* ptr);
    bool igMenuItem_Bool(const(char)* label, const(char)* shortcut = null, bool selected = false, bool enabled = true);
    bool igMenuItem_BoolPtr(const(char)* label, const(char)* shortcut, bool* p_selected, bool enabled = true);
    bool igMenuItemEx(const(char)* label, const(char)* icon, const(char)* shortcut = null, bool selected = false, bool enabled = true);
    ImGuiKey igMouseButtonToKey(ImGuiMouseButton button);
    void igMultiSelectAddSetAll(ImGuiMultiSelectTempData* ms, bool selected);
    void igMultiSelectAddSetRange(ImGuiMultiSelectTempData* ms, bool selected, int range_dir, ImGuiSelectionUserData first_item, ImGuiSelectionUserData last_item);
    void igMultiSelectItemFooter(ImGuiID id, bool* p_selected, bool* p_pressed, ImGuiMultiSelectFlags extra_flags = ImGuiMultiSelectFlags.None);
    void igMultiSelectItemHeader(ImGuiID id, bool* p_selected, ImGuiButtonFlags* p_button_flags);
    void igNavClearPreferredPosForAxis(ImGuiAxis axis);
    void igNavHighlightActivated(ImGuiID id);
    void igNavInitRequestApplyResult();
    void igNavInitWindow(ImGuiWindow* window, bool force_reinit);
    void igNavMoveRequestApplyResult();
    bool igNavMoveRequestButNoResultYet();
    void igNavMoveRequestCancel();
    void igNavMoveRequestForward(ImGuiDir move_dir, ImGuiDir clip_dir, ImGuiNavMoveFlags move_flags, ImGuiScrollFlags scroll_flags);
    void igNavMoveRequestResolveWithLastItem(ImGuiNavItemData* result);
    void igNavMoveRequestResolveWithPastTreeNode(ImGuiNavItemData* result, const ImGuiTreeNodeStackData* tree_node_data);
    void igNavMoveRequestSubmit(ImGuiDir move_dir, ImGuiDir clip_dir, ImGuiNavMoveFlags move_flags, ImGuiScrollFlags scroll_flags);
    void igNavMoveRequestTryWrapping(ImGuiWindow* window, ImGuiNavMoveFlags move_flags);
    void igNavUpdateCurrentWindowIsScrollPushableX();
    void igNewFrame();
    void igNewLine();
    void igNextColumn();
    bool igOpenPopup_Str(const(char)* str_id, ImGuiPopupFlags popup_flags = ImGuiPopupFlags.None);
    bool igOpenPopup_ID(ImGuiID id, ImGuiPopupFlags popup_flags = ImGuiPopupFlags.None);
    bool igOpenPopupEx(ImGuiID id, ImGuiPopupFlags popup_flags = ImGuiPopupFlags.None);
    bool igOpenPopupOnItemClick(const(char)* str_id = null, ImGuiPopupFlags popup_flags = ImGuiPopupFlags.None);
    int igPlotEx(ImGuiPlotType plot_type, const(char)* label, float function(void* data,int idx) values_getter, void* data, int values_count, int values_offset, const(char)* overlay_text, float scale_min, float scale_max, const ImVec2 size_arg);
    void igPlotHistogram_FloatPtr(const(char)* label, const float* values, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = float.max, float scale_max = float.max, ImVec2 graph_size = ImVec2(0,0), int stride = float.sizeof);
    void igPlotHistogram_FnFloatPtr(const(char)* label, float function(void* data,int idx) values_getter, void* data, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = float.max, float scale_max = float.max, ImVec2 graph_size = ImVec2(0,0));
    void igPlotLines_FloatPtr(const(char)* label, const float* values, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = float.max, float scale_max = float.max, ImVec2 graph_size = ImVec2(0,0), int stride = float.sizeof);
    void igPlotLines_FnFloatPtr(const(char)* label, float function(void* data,int idx) values_getter, void* data, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = float.max, float scale_max = float.max, ImVec2 graph_size = ImVec2(0,0));
    void igPopClipRect();
    void igPopColumnsBackground();
    void igPopFocusScope();
    void igPopFont();
    void igPopID();
    void igPopItemFlag();
    void igPopItemWidth();
    void igPopPasswordFont();
    void igPopStyleColor(int count = 1);
    void igPopStyleVar(int count = 1);
    void igPopTextWrapPos();
    void igProgressBar(float fraction, const ImVec2 size_arg = ImVec2(-float.min_normal,0), const(char)* overlay = null);
    void igPushClipRect(const ImVec2 clip_rect_min, const ImVec2 clip_rect_max, bool intersect_with_current_clip_rect);
    void igPushColumnClipRect(int column_index);
    void igPushColumnsBackground();
    void igPushFocusScope(ImGuiID id);
    void igPushFont(ImFont* font, float font_size_base_unscaled);
    void igPushID_Str(const(char)* str_id);
    void igPushID_StrStr(const(char)* str_id_begin, const(char)* str_id_end);
    void igPushID_Ptr(const void* ptr_id);
    void igPushID_Int(int int_id);
    void igPushItemFlag(ImGuiItemFlags option, bool enabled);
    void igPushItemWidth(float item_width);
    void igPushMultiItemsWidths(int components, float width_full);
    void igPushOverrideID(ImGuiID id);
    void igPushPasswordFont();
    void igPushStyleColor_U32(ImGuiCol idx, ImU32 col);
    void igPushStyleColor_Vec4(ImGuiCol idx, const ImVec4 col);
    void igPushStyleVar_Float(ImGuiStyleVar idx, float val);
    void igPushStyleVar_Vec2(ImGuiStyleVar idx, const ImVec2 val);
    void igPushStyleVarX(ImGuiStyleVar idx, float val_x);
    void igPushStyleVarY(ImGuiStyleVar idx, float val_y);
    void igPushTextWrapPos(float wrap_local_pos_x = 0.0f);
    bool igRadioButton_Bool(const(char)* label, bool active);
    bool igRadioButton_IntPtr(const(char)* label, int* v, int v_button);
    void igRegisterFontAtlas(ImFontAtlas* atlas);
    void igRegisterUserTexture(ImTextureData* tex);
    void igRemoveContextHook(ImGuiContext* ctx, ImGuiID hook_to_remove);
    void igRemoveSettingsHandler(const(char)* type_name);
    void igRender();
    void igRenderArrow(ImDrawList* draw_list, ImVec2 pos, ImU32 col, ImGuiDir dir, float scale = 1.0f);
    void igRenderArrowDockMenu(ImDrawList* draw_list, ImVec2 p_min, float sz, ImU32 col);
    void igRenderArrowPointingAt(ImDrawList* draw_list, ImVec2 pos, ImVec2 half_sz, ImGuiDir direction, ImU32 col);
    void igRenderBullet(ImDrawList* draw_list, ImVec2 pos, ImU32 col);
    void igRenderCheckMark(ImDrawList* draw_list, ImVec2 pos, ImU32 col, float sz);
    void igRenderColorComponentMarker(const ImRect bb, ImU32 col, float rounding);
    void igRenderColorRectWithAlphaCheckerboard(ImDrawList* draw_list, ImVec2 p_min, ImVec2 p_max, ImU32 fill_col, float grid_step, ImVec2 grid_off, float rounding = 0.0f, ImDrawFlags flags = ImDrawFlags.None);
    void igRenderDragDropTargetRectEx(ImDrawList* draw_list, const ImRect bb, float rounding);
    void igRenderDragDropTargetRectForItem(const ImRect bb);
    void igRenderFrame(ImVec2 p_min, ImVec2 p_max, ImU32 fill_col, bool borders = true, float rounding = 0.0f);
    void igRenderFrameBorder(ImVec2 p_min, ImVec2 p_max, float rounding = 0.0f);
    void igRenderMouseCursor(ImVec2 pos, float scale, ImGuiMouseCursor mouse_cursor, ImU32 col_fill, ImU32 col_border, ImU32 col_shadow);
    void igRenderNavCursor(const ImRect bb, ImGuiID id, ImGuiNavRenderCursorFlags flags = ImGuiNavRenderCursorFlags.None, float rounding = -1.0f);
    void igRenderPlatformWindowsDefault(void* platform_render_arg = null, void* renderer_render_arg = null);
    void igRenderRectFilledInRangeH(ImDrawList* draw_list, const ImRect rect, ImU32 col, float fill_x0, float fill_x1, float rounding);
    void igRenderRectFilledWithHole(ImDrawList* draw_list, const ImRect outer, const ImRect inner, ImU32 col, float rounding);
    void igRenderText(ImVec2 pos, const(char)* text, const(char)* text_end = null, bool hide_text_after_hash = true);
    void igRenderTextClipped(const ImVec2 pos_min, const ImVec2 pos_max, const(char)* text, const(char)* text_end, const ImVec2* text_size_if_known, const ImVec2 alignment = ImVec2(0,0), const ImRect* clip_rect = null);
    void igRenderTextClippedEx(ImDrawList* draw_list, const ImVec2 pos_min, const ImVec2 pos_max, const(char)* text, const(char)* text_end, const ImVec2* text_size_if_known, const ImVec2 alignment = ImVec2(0,0), const ImRect* clip_rect = null);
    void igRenderTextEllipsis(ImDrawList* draw_list, const ImVec2 pos_min, const ImVec2 pos_max, float ellipsis_max_x, const(char)* text, const(char)* text_end, const ImVec2* text_size_if_known);
    void igRenderTextWrapped(ImVec2 pos, const(char)* text, const(char)* text_end, float wrap_width);
    void igResetMouseDragDelta(ImGuiMouseButton button = ImGuiMouseButton.Left);
    void igSameLine(float offset_from_start_x = 0.0f, float spacing = -1.0f);
    void igSaveIniSettingsToDisk(const(char)* ini_filename);
    const(char)* igSaveIniSettingsToMemory(size_t* out_ini_size = null);
    void igScaleWindowsInViewport(ImGuiViewportP* viewport, float scale);
    void igScrollToBringRectIntoView(ImGuiWindow* window, const ImRect rect);
    void igScrollToItem(ImGuiScrollFlags flags = ImGuiScrollFlags.None);
    void igScrollToRect(ImGuiWindow* window, const ImRect rect, ImGuiScrollFlags flags = ImGuiScrollFlags.None);
    ImVec2 igScrollToRectEx(ImGuiWindow* window, const ImRect rect, ImGuiScrollFlags flags = ImGuiScrollFlags.None);
    void igScrollbar(ImGuiAxis axis);
    bool igScrollbarEx(const ImRect bb, ImGuiID id, ImGuiAxis axis, ImS64* p_scroll_v, ImS64 avail_v, ImS64 contents_v, ImDrawFlags draw_rounding_flags = ImDrawFlags.None);
    bool igSelectable_Bool(const(char)* label, bool selected = false, ImGuiSelectableFlags flags = ImGuiSelectableFlags.None, const ImVec2 size = ImVec2(0,0));
    bool igSelectable_BoolPtr(const(char)* label, bool* p_selected, ImGuiSelectableFlags flags = ImGuiSelectableFlags.None, const ImVec2 size = ImVec2(0,0));
    void igSeparator();
    void igSeparatorEx(ImGuiSeparatorFlags flags, float thickness = 1.0f);
    void igSeparatorText(const(char)* label);
    void igSeparatorTextEx(ImGuiID id, const(char)* label, const(char)* label_end, float extra_width);
    void igSetActiveID(ImGuiID id, ImGuiWindow* window);
    void igSetActiveIdUsingAllKeyboardKeys();
    void igSetAllocatorFunctions(ImGuiMemAllocFunc alloc_func, ImGuiMemFreeFunc free_func, void* user_data = null);
    void igSetClipboardText(const(char)* text);
    void igSetColumnOffset(int column_index, float offset_x);
    void igSetColumnWidth(int column_index, float width);
    void igSetContextName(ImGuiContext* ctx, const(char)* name);
    void igSetCurrentContext(ImGuiContext* ctx);
    void igSetCurrentFont(ImFont* font, float font_size_before_scaling, float font_size_after_scaling);
    void igSetCurrentViewport(ImGuiWindow* window, ImGuiViewportP* viewport);
    void igSetCursorPos(const ImVec2 local_pos);
    void igSetCursorPosX(float local_x);
    void igSetCursorPosY(float local_y);
    void igSetCursorScreenPos(const ImVec2 pos);
    bool igSetDragDropPayload(const(char)* type, const void* data, size_t sz, ImGuiCond cond = ImGuiCond.None);
    void igSetFocusID(ImGuiID id, ImGuiWindow* window);
    void igSetFontRasterizerDensity(float rasterizer_density);
    void igSetHoveredID(ImGuiID id);
    void igSetItemDefaultFocus();
    bool igSetItemKeyOwner_Nil(ImGuiKey key);
    bool igSetItemKeyOwner_InputFlags(ImGuiKey key, ImGuiInputFlags flags);
    void igSetItemTooltip(const(char)* fmt, ...);
    void igSetItemTooltipV(const(char)* fmt, va_list args);
    void igSetKeyOwner(ImGuiKey key, ImGuiID owner_id, ImGuiInputFlags flags = ImGuiInputFlags.None);
    void igSetKeyOwnersForKeyChord(ImGuiKeyChord key, ImGuiID owner_id, ImGuiInputFlags flags = ImGuiInputFlags.None);
    void igSetKeyboardFocusHere(int offset = 0);
    void igSetLastItemData(ImGuiID item_id, ImGuiItemFlags item_flags, ImGuiItemStatusFlags status_flags, const ImRect item_rect);
    void igSetMouseCursor(ImGuiMouseCursor cursor_type);
    void igSetNavCursorVisible(bool visible);
    void igSetNavCursorVisibleAfterMove();
    void igSetNavFocusScope(ImGuiID focus_scope_id);
    void igSetNavID(ImGuiID id, ImGuiNavLayer nav_layer, ImGuiID focus_scope_id, const ImRect rect_rel);
    void igSetNavWindow(ImGuiWindow* window);
    void igSetNextFrameWantCaptureKeyboard(bool want_capture_keyboard);
    void igSetNextFrameWantCaptureMouse(bool want_capture_mouse);
    void igSetNextItemAllowOverlap();
    void igSetNextItemColorMarker(ImU32 col);
    void igSetNextItemOpen(bool is_open, ImGuiCond cond = ImGuiCond.None);
    void igSetNextItemRefVal(ImGuiDataType data_type, void* p_data);
    void igSetNextItemSelectionUserData(ImGuiSelectionUserData selection_user_data);
    void igSetNextItemShortcut(ImGuiKeyChord key_chord, ImGuiInputFlags flags = ImGuiInputFlags.None);
    void igSetNextItemStorageID(ImGuiID storage_id);
    void igSetNextItemWidth(float item_width);
    void igSetNextWindowBgAlpha(float alpha);
    void igSetNextWindowClass(const ImGuiWindowClass* window_class);
    void igSetNextWindowCollapsed(bool collapsed, ImGuiCond cond = ImGuiCond.None);
    void igSetNextWindowContentSize(const ImVec2 size);
    void igSetNextWindowDockID(ImGuiID dock_id, ImGuiCond cond = ImGuiCond.None);
    void igSetNextWindowFocus();
    void igSetNextWindowPos(const ImVec2 pos, ImGuiCond cond = ImGuiCond.None, const ImVec2 pivot = ImVec2(0,0));
    void igSetNextWindowRefreshPolicy(ImGuiWindowRefreshFlags flags);
    void igSetNextWindowScroll(const ImVec2 scroll);
    void igSetNextWindowSize(const ImVec2 size, ImGuiCond cond = ImGuiCond.None);
    void igSetNextWindowSizeConstraints(const ImVec2 size_min, const ImVec2 size_max, ImGuiSizeCallback custom_callback = null, void* custom_callback_data = null);
    void igSetNextWindowViewport(ImGuiID viewport_id);
    void igSetScrollFromPosX_Float(float local_x, float center_x_ratio = 0.5f);
    void igSetScrollFromPosX_WindowPtr(ImGuiWindow* window, float local_x, float center_x_ratio);
    void igSetScrollFromPosY_Float(float local_y, float center_y_ratio = 0.5f);
    void igSetScrollFromPosY_WindowPtr(ImGuiWindow* window, float local_y, float center_y_ratio);
    void igSetScrollHereX(float center_x_ratio = 0.5f);
    void igSetScrollHereY(float center_y_ratio = 0.5f);
    void igSetScrollX_Float(float scroll_x);
    void igSetScrollX_WindowPtr(ImGuiWindow* window, float scroll_x);
    void igSetScrollY_Float(float scroll_y);
    void igSetScrollY_WindowPtr(ImGuiWindow* window, float scroll_y);
    bool igSetShortcutRouting(ImGuiKeyChord key_chord, ImGuiInputFlags flags, ImGuiID owner_id);
    void igSetStateStorage(ImGuiStorage* storage);
    void igSetTabItemClosed(const(char)* tab_or_docked_window_label);
    void igSetTooltip(const(char)* fmt, ...);
    void igSetTooltipV(const(char)* fmt, va_list args);
    void igSetWindowClipRectBeforeSetChannel(ImGuiWindow* window, const ImRect clip_rect);
    void igSetWindowCollapsed_Bool(bool collapsed, ImGuiCond cond = ImGuiCond.None);
    void igSetWindowCollapsed_Str(const(char)* name, bool collapsed, ImGuiCond cond = ImGuiCond.None);
    void igSetWindowCollapsed_WindowPtr(ImGuiWindow* window, bool collapsed, ImGuiCond cond = ImGuiCond.None);
    void igSetWindowDock(ImGuiWindow* window, ImGuiID dock_id, ImGuiCond cond);
    void igSetWindowFocus_Nil();
    void igSetWindowFocus_Str(const(char)* name);
    void igSetWindowHiddenAndSkipItemsForCurrentFrame(ImGuiWindow* window);
    void igSetWindowHitTestHole(ImGuiWindow* window, const ImVec2 pos, const ImVec2 size);
    void igSetWindowParentWindowForFocusRoute(ImGuiWindow* window, ImGuiWindow* parent_window);
    void igSetWindowPos_Vec2(const ImVec2 pos, ImGuiCond cond = ImGuiCond.None);
    void igSetWindowPos_Str(const(char)* name, const ImVec2 pos, ImGuiCond cond = ImGuiCond.None);
    void igSetWindowPos_WindowPtr(ImGuiWindow* window, const ImVec2 pos, ImGuiCond cond = ImGuiCond.None);
    void igSetWindowSize_Vec2(const ImVec2 size, ImGuiCond cond = ImGuiCond.None);
    void igSetWindowSize_Str(const(char)* name, const ImVec2 size, ImGuiCond cond = ImGuiCond.None);
    void igSetWindowSize_WindowPtr(ImGuiWindow* window, const ImVec2 size, ImGuiCond cond = ImGuiCond.None);
    void igSetWindowViewport(ImGuiWindow* window, ImGuiViewportP* viewport);
    void igShadeVertsLinearColorGradientKeepAlpha(ImDrawList* draw_list, int vert_start_idx, int vert_end_idx, ImVec2 gradient_p0, ImVec2 gradient_p1, ImU32 col0, ImU32 col1);
    void igShadeVertsLinearUV(ImDrawList* draw_list, int vert_start_idx, int vert_end_idx, const ImVec2 a, const ImVec2 b, const ImVec2 uv_a, const ImVec2 uv_b, bool clamp);
    void igShadeVertsTransformPos(ImDrawList* draw_list, int vert_start_idx, int vert_end_idx, const ImVec2 pivot_in, float cos_a, float sin_a, const ImVec2 pivot_out);
    bool igShortcut_Nil(ImGuiKeyChord key_chord, ImGuiInputFlags flags = ImGuiInputFlags.None);
    bool igShortcut_ID(ImGuiKeyChord key_chord, ImGuiInputFlags flags, ImGuiID owner_id);
    void igShowAboutWindow(bool* p_open = null);
    void igShowDebugLogWindow(bool* p_open = null);
    void igShowDemoWindow(bool* p_open = null);
    void igShowFontAtlas(ImFontAtlas* atlas);
    void igShowFontSelector(const(char)* label);
    void igShowIDStackToolWindow(bool* p_open = null);
    void igShowMetricsWindow(bool* p_open = null);
    void igShowStyleEditor(ImGuiStyle* reference = null);
    bool igShowStyleSelector(const(char)* label);
    void igShowUserGuide();
    void igShrinkWidths(ImGuiShrinkWidthItem* items, int count, float width_excess, float width_min);
    void igShutdown();
    bool igSliderAngle(const(char)* label, float* v_rad, float v_degrees_min = -360.0f, float v_degrees_max = +360.0f, const(char)* format = "%.0f deg", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igSliderBehavior(const ImRect bb, ImGuiID id, ImGuiDataType data_type, void* p_v, const void* p_min, const void* p_max, const(char)* format, ImGuiSliderFlags flags, ImRect* out_grab_bb);
    bool igSliderFloat(const(char)* label, float* v, float v_min, float v_max, const(char)* format = "%.3f", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igSliderFloat2(const(char)* label, float[2]*/*[2]*/ v, float v_min, float v_max, const(char)* format = "%.3f", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igSliderFloat3(const(char)* label, float[3]*/*[3]*/ v, float v_min, float v_max, const(char)* format = "%.3f", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igSliderFloat4(const(char)* label, float[4]*/*[4]*/ v, float v_min, float v_max, const(char)* format = "%.3f", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igSliderInt(const(char)* label, int* v, int v_min, int v_max, const(char)* format = "%d", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igSliderInt2(const(char)* label, int[2]*/*[2]*/ v, int v_min, int v_max, const(char)* format = "%d", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igSliderInt3(const(char)* label, int[3]*/*[3]*/ v, int v_min, int v_max, const(char)* format = "%d", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igSliderInt4(const(char)* label, int[4]*/*[4]*/ v, int v_min, int v_max, const(char)* format = "%d", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igSliderScalar(const(char)* label, ImGuiDataType data_type, void* p_data, const void* p_min, const void* p_max, const(char)* format = null, ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igSliderScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, const void* p_min, const void* p_max, const(char)* format = null, ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igSmallButton(const(char)* label);
    void igSpacing();
    bool igSplitterBehavior(const ImRect bb, ImGuiID id, ImGuiAxis axis, float* size1, float* size2, float min_size1, float min_size2, float hover_extend = 0.0f, float hover_visibility_delay = 0.0f, ImU32 bg_col = 0);
    void igStartMouseMovingWindow(ImGuiWindow* window);
    void igStartMouseMovingWindowOrNode(ImGuiWindow* window, ImGuiDockNode* node, bool undock);
    void igStopMouseMovingWindow();
    void igStyleColorsClassic(ImGuiStyle* dst = null);
    void igStyleColorsDark(ImGuiStyle* dst = null);
    void igStyleColorsLight(ImGuiStyle* dst = null);
    void igTabBarAddTab(ImGuiTabBar* tab_bar, ImGuiTabItemFlags tab_flags, ImGuiWindow* window);
    void igTabBarCloseTab(ImGuiTabBar* tab_bar, ImGuiTabItem* tab);
    ImGuiTabBar* igTabBarFindByID(ImGuiID id);
    ImGuiTabItem* igTabBarFindMostRecentlySelectedTabForActiveWindow(ImGuiTabBar* tab_bar);
    ImGuiTabItem* igTabBarFindTabByID(ImGuiTabBar* tab_bar, ImGuiID tab_id);
    ImGuiTabItem* igTabBarFindTabByOrder(ImGuiTabBar* tab_bar, int order);
    ImGuiTabItem* igTabBarGetCurrentTab(ImGuiTabBar* tab_bar);
    const(char)* igTabBarGetTabName(ImGuiTabBar* tab_bar, ImGuiTabItem* tab);
    int igTabBarGetTabOrder(ImGuiTabBar* tab_bar, ImGuiTabItem* tab);
    bool igTabBarProcessReorder(ImGuiTabBar* tab_bar);
    void igTabBarQueueFocus_TabItemPtr(ImGuiTabBar* tab_bar, ImGuiTabItem* tab);
    void igTabBarQueueFocus_Str(ImGuiTabBar* tab_bar, const(char)* tab_name);
    void igTabBarQueueReorder(ImGuiTabBar* tab_bar, ImGuiTabItem* tab, int offset);
    void igTabBarQueueReorderFromMousePos(ImGuiTabBar* tab_bar, ImGuiTabItem* tab, ImVec2 mouse_pos);
    void igTabBarRemove(ImGuiTabBar* tab_bar);
    void igTabBarRemoveTab(ImGuiTabBar* tab_bar, ImGuiID tab_id);
    void igTabItemBackground(ImDrawList* draw_list, const ImRect bb, ImGuiTabItemFlags flags, ImU32 col);
    bool igTabItemButton(const(char)* label, ImGuiTabItemFlags flags = ImGuiTabItemFlags.None);
    ImVec2 igTabItemCalcSize_Str(const(char)* label, bool has_close_button_or_unsaved_marker);
    ImVec2 igTabItemCalcSize_WindowPtr(ImGuiWindow* window);
    bool igTabItemEx(ImGuiTabBar* tab_bar, const(char)* label, bool* p_open, ImGuiTabItemFlags flags, ImGuiWindow* docked_window);
    void igTabItemLabelAndCloseButton(ImDrawList* draw_list, const ImRect bb, ImGuiTabItemFlags flags, ImVec2 frame_padding, const(char)* label, ImGuiID tab_id, ImGuiID close_button_id, bool is_contents_visible, bool* out_just_closed, bool* out_text_clipped);
    void igTabItemSpacing(const(char)* str_id, ImGuiTabItemFlags flags, float width);
    void igTableAngledHeadersRow();
    void igTableAngledHeadersRowEx(ImGuiID row_id, float angle, float max_label_width, const ImGuiTableHeaderData* data, int data_count);
    void igTableApplyExternalUnclipRect(ImGuiTable* table, ImRect* rect);
    void igTableApplyQueuedRequests(ImGuiTable* table);
    void igTableBeginCell(ImGuiTable* table, int column_n);
    bool igTableBeginContextMenuPopup(ImGuiTable* table);
    void igTableBeginInitMemory(ImGuiTable* table, int columns_count);
    void igTableBeginRow(ImGuiTable* table);
    float igTableCalcMaxColumnWidth(const ImGuiTable* table, int column_n);
    void igTableDrawBorders(ImGuiTable* table);
    void igTableDrawDefaultContextMenu(ImGuiTable* table, ImGuiTableFlags flags_for_section_to_display);
    void igTableEndCell(ImGuiTable* table);
    void igTableEndRow(ImGuiTable* table);
    ImGuiTable* igTableFindByID(ImGuiID id);
    void igTableFixColumnSortDirection(ImGuiTable* table, ImGuiTableColumn* column);
    void igTableFixDisplayOrder(ImGuiTable* table);
    void igTableGcCompactSettings();
    void igTableGcCompactTransientBuffers_TablePtr(ImGuiTable* table);
    void igTableGcCompactTransientBuffers_TableTempDataPtr(ImGuiTableTempData* table);
    ImGuiTableSettings* igTableGetBoundSettings(ImGuiTable* table);
    ImRect igTableGetCellBgRect(const ImGuiTable* table, int column_n);
    int igTableGetColumnCount();
    ImGuiTableColumnFlags igTableGetColumnFlags(int column_n = -1);
    int igTableGetColumnIndex();
    const(char)* igTableGetColumnName_Int(int column_n = -1);
    const(char)* igTableGetColumnName_TablePtr(const ImGuiTable* table, int column_n);
    ImGuiSortDirection igTableGetColumnNextSortDirection(ImGuiTableColumn* column);
    ImGuiID igTableGetColumnResizeID(ImGuiTable* table, int column_n, int instance_no = 0);
    float igTableGetColumnWidthAuto(ImGuiTable* table, ImGuiTableColumn* column);
    float igTableGetHeaderAngledMaxLabelWidth();
    float igTableGetHeaderRowHeight();
    int igTableGetHoveredColumn();
    int igTableGetHoveredRow();
    ImGuiTableInstanceData* igTableGetInstanceData(ImGuiTable* table, int instance_no);
    ImGuiID igTableGetInstanceID(ImGuiTable* table, int instance_no);
    int igTableGetRowIndex();
    ImGuiTableSortSpecs* igTableGetSortSpecs();
    void igTableHeader(const(char)* label);
    void igTableHeadersRow();
    void igTableInitColumnDefaults(ImGuiTable* table, ImGuiTableColumn* column, ImGuiTableColumnFlags init_mask);
    void igTableLoadSettings(ImGuiTable* table);
    void igTableLoadSettingsForColumn(ImGuiTableColumn* column, ImGuiTableColumnSettings* column_settings, ImGuiTableFlags load_flags);
    void igTableLoadSettingsForColumns(ImGuiTable* table);
    void igTableMergeDrawChannels(ImGuiTable* table);
    bool igTableNextColumn();
    void igTableNextRow(ImGuiTableRowFlags row_flags = ImGuiTableRowFlags.None, float min_row_height = 0.0f);
    void igTableOpenContextMenu(int column_n = -1);
    void igTablePopBackgroundChannel();
    void igTablePopColumnChannel();
    void igTablePushBackgroundChannel();
    void igTablePushColumnChannel(int column_n);
    void igTableQueueSetColumnDisplayOrder(ImGuiTable* table, int column_n, int dst_order);
    void igTableReconcileColumns(ImGuiTable* table);
    void igTableRemove(ImGuiTable* table);
    void igTableResetSettings(ImGuiTable* table);
    void igTableSaveSettings(ImGuiTable* table);
    void igTableSetBgColor(ImGuiTableBgTarget target, ImU32 color, int column_n = -1);
    void igTableSetColumnDisplayOrder(ImGuiTable* table, int column_n, int dst_order);
    void igTableSetColumnEnabled(int column_n, bool v);
    bool igTableSetColumnIndex(int column_n);
    void igTableSetColumnSortDirection(int column_n, ImGuiSortDirection sort_direction, bool append_to_sort_specs);
    void igTableSetColumnWidth(int column_n, float width);
    void igTableSetColumnWidthAutoAll(ImGuiTable* table);
    void igTableSetColumnWidthAutoSingle(ImGuiTable* table, int column_n);
    void igTableSettingsAddSettingsHandler();
    ImGuiTableSettings* igTableSettingsCreate(ImGuiID id, int columns_count);
    ImGuiTableSettings* igTableSettingsFindByID(ImGuiID id);
    void igTableSetupColumn(const(char)* label, ImGuiTableColumnFlags flags = ImGuiTableColumnFlags.None, float init_width_or_weight = 0.0f, ImGuiID user_data = 0);
    void igTableSetupDrawChannels(ImGuiTable* table);
    void igTableSetupScrollFreeze(int cols, int rows);
    void igTableSortSpecsBuild(ImGuiTable* table);
    void igTableSortSpecsSanitize(ImGuiTable* table);
    void igTableUpdateBorders(ImGuiTable* table);
    void igTableUpdateColumnsWeightFromWidth(ImGuiTable* table);
    void igTableUpdateLayout(ImGuiTable* table);
    void igTeleportMousePos(const ImVec2 pos);
    bool igTempInputIsActive(ImGuiID id);
    bool igTempInputScalar(const ImRect bb, ImGuiID id, const(char)* label, ImGuiDataType data_type, void* p_data, const(char)* format, const void* p_clamp_min = null, const void* p_clamp_max = null);
    bool igTempInputText(const ImRect bb, ImGuiID id, const(char)* label, char* buf, size_t buf_size, ImGuiInputTextFlags flags = ImGuiInputTextFlags.None, ImGuiInputTextCallback callback = null, void* user_data = null);
    bool igTestKeyOwner(ImGuiKey key, ImGuiID owner_id);
    bool igTestShortcutRouting(ImGuiKeyChord key_chord, ImGuiID owner_id);
    void igText(const(char)* fmt, ...);
    void igTextAligned(float align_x, float size_x, const(char)* fmt, ...);
    void igTextAlignedV(float align_x, float size_x, const(char)* fmt, va_list args);
    void igTextColored(const ImVec4 col, const(char)* fmt, ...);
    void igTextColoredV(const ImVec4 col, const(char)* fmt, va_list args);
    void igTextDisabled(const(char)* fmt, ...);
    void igTextDisabledV(const(char)* fmt, va_list args);
    void igTextEx(const(char)* text, const(char)* text_end = null, ImGuiTextFlags flags = ImGuiTextFlags.None);
    bool igTextLink(const(char)* label);
    bool igTextLinkOpenURL(const(char)* label, const(char)* url = null);
    void igTextUnformatted(const(char)* text, const(char)* text_end = null);
    void igTextV(const(char)* fmt, va_list args);
    void igTextWrapped(const(char)* fmt, ...);
    void igTextWrappedV(const(char)* fmt, va_list args);
    void igTranslateWindowsInViewport(ImGuiViewportP* viewport, const ImVec2 old_pos, const ImVec2 new_pos, const ImVec2 old_size, const ImVec2 new_size);
    bool igTreeNode_Str(const(char)* label);
    bool igTreeNode_StrStr(const(char)* str_id, const(char)* fmt, ...);
    bool igTreeNode_Ptr(const void* ptr_id, const(char)* fmt, ...);
    bool igTreeNodeBehavior(ImGuiID id, ImGuiTreeNodeFlags flags, const(char)* label, const(char)* label_end = null);
    void igTreeNodeDrawLineToChildNode(const ImVec2 target_pos);
    void igTreeNodeDrawLineToTreePop(const ImGuiTreeNodeStackData* data);
    bool igTreeNodeEx_Str(const(char)* label, ImGuiTreeNodeFlags flags = ImGuiTreeNodeFlags.None);
    bool igTreeNodeEx_StrStr(const(char)* str_id, ImGuiTreeNodeFlags flags, const(char)* fmt, ...);
    bool igTreeNodeEx_Ptr(const void* ptr_id, ImGuiTreeNodeFlags flags, const(char)* fmt, ...);
    bool igTreeNodeExV_Str(const(char)* str_id, ImGuiTreeNodeFlags flags, const(char)* fmt, va_list args);
    bool igTreeNodeExV_Ptr(const void* ptr_id, ImGuiTreeNodeFlags flags, const(char)* fmt, va_list args);
    bool igTreeNodeGetOpen(ImGuiID storage_id);
    void igTreeNodeSetOpen(ImGuiID storage_id, bool open);
    bool igTreeNodeUpdateNextOpen(ImGuiID storage_id, ImGuiTreeNodeFlags flags);
    bool igTreeNodeV_Str(const(char)* str_id, const(char)* fmt, va_list args);
    bool igTreeNodeV_Ptr(const void* ptr_id, const(char)* fmt, va_list args);
    void igTreePop();
    void igTreePush_Str(const(char)* str_id);
    void igTreePush_Ptr(const void* ptr_id);
    void igTreePushOverrideID(ImGuiID id);
    int igTypingSelectFindBestLeadingMatch(ImGuiTypingSelectRequest* req, int items_count, const(char)* function(void*,int) get_item_name_func, void* user_data);
    int igTypingSelectFindMatch(ImGuiTypingSelectRequest* req, int items_count, const(char)* function(void*,int) get_item_name_func, void* user_data, int nav_item_idx);
    int igTypingSelectFindNextSingleCharMatch(ImGuiTypingSelectRequest* req, int items_count, const(char)* function(void*,int) get_item_name_func, void* user_data, int nav_item_idx);
    void igUnindent(float indent_w = 0.0f);
    void igUnregisterFontAtlas(ImFontAtlas* atlas);
    void igUnregisterUserTexture(ImTextureData* tex);
    void igUpdateCurrentFontSize(float restore_font_size_after_scaling);
    void igUpdateHoveredWindowAndCaptureFlags(const ImVec2 mouse_pos);
    void igUpdateInputEvents(bool trickle_fast_inputs);
    void igUpdateMouseMovingWindowEndFrame();
    void igUpdateMouseMovingWindowNewFrame();
    void igUpdatePlatformWindows();
    void igUpdateWindowParentAndRootLinks(ImGuiWindow* window, ImGuiWindowFlags flags, ImGuiWindow* parent_window);
    void igUpdateWindowSkipRefresh(ImGuiWindow* window);
    bool igVSliderFloat(const(char)* label, const ImVec2 size, float* v, float v_min, float v_max, const(char)* format = "%.3f", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igVSliderInt(const(char)* label, const ImVec2 size, int* v, int v_min, int v_max, const(char)* format = "%d", ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    bool igVSliderScalar(const(char)* label, const ImVec2 size, ImGuiDataType data_type, void* p_data, const void* p_min, const void* p_max, const(char)* format = null, ImGuiSliderFlags flags = ImGuiSliderFlags.None);
    void igValue_Bool(const(char)* prefix, bool b);
    void igValue_Int(const(char)* prefix, int v);
    void igValue_Uint(const(char)* prefix, uint v);
    void igValue_Float(const(char)* prefix, float v, const(char)* float_format = null);
    ImVec2 igWindowPosAbsToRel(ImGuiWindow* window, const ImVec2 p);
    ImVec2 igWindowPosRelToAbs(ImGuiWindow* window, const ImVec2 p);
    ImRect igWindowRectAbsToRel(ImGuiWindow* window, const ImRect r);
    ImRect igWindowRectRelToAbs(ImGuiWindow* window, const ImRect r);
}
extern (C) @nogc nothrow {
    version (USE_GLFW) {
        import bindbc.glfw;

        void ImGui_ImplGlfw_InstallCallbacks(GLFWwindow* window);
        void ImGui_ImplGlfw_MonitorCallback(GLFWmonitor* monitor, int event);
        float ImGui_ImplGlfw_GetContentScaleForWindow(GLFWwindow* window);
        void ImGui_ImplGlfw_NewFrame();
        bool ImGui_ImplGlfw_InitForOther(GLFWwindow* window, bool install_callbacks);
        bool ImGui_ImplGlfw_InitForVulkan(GLFWwindow* window, bool install_callbacks);
        void ImGui_ImplGlfw_SetCallbacksChainForAllWindows(bool chain_for_all_windows);
        void ImGui_ImplGlfw_CharCallback(GLFWwindow* window, uint c);
        bool ImGui_ImplGlfw_InitForOpenGL(GLFWwindow* window, bool install_callbacks);
        float ImGui_ImplGlfw_GetContentScaleForMonitor(GLFWmonitor* monitor);
        void ImGui_ImplGlfw_KeyCallback(GLFWwindow* window, int key, int scancode, int action, int mods);
        void ImGui_ImplGlfw_ScrollCallback(GLFWwindow* window, double xoffset, double yoffset);
        void ImGui_ImplGlfw_MouseButtonCallback(GLFWwindow* window, int button, int action, int mods);
        void ImGui_ImplGlfw_CursorPosCallback(GLFWwindow* window, double x, double y);
        void ImGui_ImplGlfw_RestoreCallbacks(GLFWwindow* window);
        void ImGui_ImplGlfw_WindowFocusCallback(GLFWwindow* window, int focused);
        void ImGui_ImplGlfw_Shutdown();
        void ImGui_ImplGlfw_Sleep(int milliseconds);
        void ImGui_ImplGlfw_CursorEnterCallback(GLFWwindow* window, int entered);
    }
    version (USE_OpenGL3) {
        struct ImGui_ImplOpenGL3_RenderState { bool UseBindSampler; bool UseTexParameterFilter; uint CurrentSampler; uint CurrentTexParameterFilter; }

        bool ImGui_ImplOpenGL3_CreateDeviceObjects();
        bool ImGui_ImplOpenGL3_Init(const(char)* glsl_version = null);
        void ImGui_ImplOpenGL3_DestroyDeviceObjects();
        void ImGui_ImplOpenGL3_NewFrame();
        void ImGui_ImplOpenGL3_Shutdown();
        void ImGui_ImplOpenGL3_UpdateTexture(ImTextureData* tex);
        ImGui_ImplOpenGL3_RenderState* ImGui_ImplOpenGL3_GetRenderState();
        void ImGui_ImplOpenGL3_RenderDrawData(ImDrawData* draw_data);
    }
    version (USE_OpenGL2) {

        bool ImGui_ImplOpenGL2_CreateDeviceObjects();
        bool ImGui_ImplOpenGL2_Init();
        void ImGui_ImplOpenGL2_DestroyDeviceObjects();
        void ImGui_ImplOpenGL2_UpdateTexture(ImTextureData* tex);
        void ImGui_ImplOpenGL2_NewFrame();
        void ImGui_ImplOpenGL2_RenderDrawData(ImDrawData* draw_data);
        void ImGui_ImplOpenGL2_Shutdown();
    }
    version (USE_SDL2) {
        import bindbc.sdl;
        enum ImGui_ImplSDL2_GamepadMode { AutoFirst, AutoAll, Manual }
        enum ImGui_ImplSDL2_MouseCaptureMode { Enabled, EnabledAfterDrag, Disabled }

        void ImGui_ImplSDL2_Shutdown();
        bool ImGui_ImplSDL2_InitForMetal(SDL_Window* window);
        bool ImGui_ImplSDL2_InitForOpenGL(SDL_Window* window, void* sdl_gl_context);
        bool ImGui_ImplSDL2_InitForVulkan(SDL_Window* window);
        bool ImGui_ImplSDL2_InitForOther(SDL_Window* window);
        bool ImGui_ImplSDL2_InitForD3D(SDL_Window* window);
        float ImGui_ImplSDL2_GetContentScaleForDisplay(int display_index);
        bool ImGui_ImplSDL2_ProcessEvent(const SDL_Event* event);
        bool ImGui_ImplSDL2_InitForSDLRenderer(SDL_Window* window, SDL_Renderer* renderer);
        void ImGui_ImplSDL2_SetMouseCaptureMode(ImGui_ImplSDL2_MouseCaptureMode mode);
        void ImGui_ImplSDL2_NewFrame();
        float ImGui_ImplSDL2_GetContentScaleForWindow(SDL_Window* window);
        void ImGui_ImplSDL2_SetGamepadMode(ImGui_ImplSDL2_GamepadMode mode, SDL_GameController** manual_gamepads_array = null, int manual_gamepads_count = -1);
    }
}

auto igGenFuncC(T)(T func) {
  import std.traits;
  extern(C) ReturnType!T f(Parameters!T args)
  {
    static if (is(ReturnType!T == void)) 
    {
      func(args);
    } else 
    {
      return func(args);
    }
  }

  return &f;
}
pragma(inline):
ImColor*  ImColor_ImColor()
{
    return  ImColor_ImColor_Nil();
}

pragma(inline):
ImColor*  ImColor_ImColor(float r, float g, float b, float a = 1.0f)
{
    return  ImColor_ImColor_Float(r, g, b, a);
}

pragma(inline):
ImColor*  ImColor_ImColor(const ImVec4 col)
{
    return  ImColor_ImColor_Vec4(col);
}

pragma(inline):
ImColor*  ImColor_ImColor(int r, int g, int b, int a = 255)
{
    return  ImColor_ImColor_Int(r, g, b, a);
}

pragma(inline):
ImColor*  ImColor_ImColor(ImU32 rgba)
{
    return  ImColor_ImColor_U32(rgba);
}

pragma(inline):
void  ImDrawList_AddText(ImDrawList* self, const ImVec2 pos, ImU32 col, const(char)* text_begin, const(char)* text_end = null)
{
     ImDrawList_AddText_Vec2(self, pos, col, text_begin, text_end);
}

pragma(inline):
void  ImDrawList_AddText(ImDrawList* self, ImFont* font, float font_size, const ImVec2 pos, ImU32 col, const(char)* text_begin, const(char)* text_end = null, float wrap_width = 0.0f, const(ImVec4)* cpu_fine_clip_rect = null)
{
     ImDrawList_AddText_FontPtr(self, font, font_size, pos, col, text_begin, text_end, wrap_width, cpu_fine_clip_rect);
}

pragma(inline):
ImGuiPackedDate*  ImGuiPackedDate_ImGuiPackedDate()
{
    return  ImGuiPackedDate_ImGuiPackedDate_Nil();
}

pragma(inline):
ImGuiPackedDate*  ImGuiPackedDate_ImGuiPackedDate(int yyyymmdd)
{
    return  ImGuiPackedDate_ImGuiPackedDate_Int(yyyymmdd);
}

pragma(inline):
ImGuiPtrOrIndex*  ImGuiPtrOrIndex_ImGuiPtrOrIndex(void* ptr)
{
    return  ImGuiPtrOrIndex_ImGuiPtrOrIndex_Ptr(ptr);
}

pragma(inline):
ImGuiPtrOrIndex*  ImGuiPtrOrIndex_ImGuiPtrOrIndex(int index)
{
    return  ImGuiPtrOrIndex_ImGuiPtrOrIndex_Int(index);
}

pragma(inline):
ImGuiStoragePair*  ImGuiStoragePair_ImGuiStoragePair(ImGuiID _key, int _val)
{
    return  ImGuiStoragePair_ImGuiStoragePair_Int(_key, _val);
}

pragma(inline):
ImGuiStoragePair*  ImGuiStoragePair_ImGuiStoragePair(ImGuiID _key, float _val)
{
    return  ImGuiStoragePair_ImGuiStoragePair_Float(_key, _val);
}

pragma(inline):
ImGuiStoragePair*  ImGuiStoragePair_ImGuiStoragePair(ImGuiID _key, void* _val)
{
    return  ImGuiStoragePair_ImGuiStoragePair_Ptr(_key, _val);
}

pragma(inline):
ImGuiStyleMod*  ImGuiStyleMod_ImGuiStyleMod(ImGuiStyleVar idx, int v)
{
    return  ImGuiStyleMod_ImGuiStyleMod_Int(idx, v);
}

pragma(inline):
ImGuiStyleMod*  ImGuiStyleMod_ImGuiStyleMod(ImGuiStyleVar idx, float v)
{
    return  ImGuiStyleMod_ImGuiStyleMod_Float(idx, v);
}

pragma(inline):
ImGuiStyleMod*  ImGuiStyleMod_ImGuiStyleMod(ImGuiStyleVar idx, ImVec2 v)
{
    return  ImGuiStyleMod_ImGuiStyleMod_Vec2(idx, v);
}

pragma(inline):
ImGuiTextRange*  ImGuiTextRange_ImGuiTextRange()
{
    return  ImGuiTextRange_ImGuiTextRange_Nil();
}

pragma(inline):
ImGuiTextRange*  ImGuiTextRange_ImGuiTextRange(const(char)* _b, const(char)* _e)
{
    return  ImGuiTextRange_ImGuiTextRange_Str(_b, _e);
}

pragma(inline):
ImGuiID  ImGuiWindow_GetID(ImGuiWindow* self, const(char)* str, const(char)* str_end = null)
{
    return  ImGuiWindow_GetID_Str(self, str, str_end);
}

pragma(inline):
ImGuiID  ImGuiWindow_GetID(ImGuiWindow* self, const void* ptr)
{
    return  ImGuiWindow_GetID_Ptr(self, ptr);
}

pragma(inline):
ImGuiID  ImGuiWindow_GetID(ImGuiWindow* self, int n)
{
    return  ImGuiWindow_GetID_Int(self, n);
}

pragma(inline):
void  ImRect_Add(ImRect* self, const ImVec2 p)
{
     ImRect_Add_Vec2(self, p);
}

pragma(inline):
void  ImRect_Add(ImRect* self, const ImRect r)
{
     ImRect_Add_Rect(self, r);
}

pragma(inline):
bool  ImRect_Contains(ImRect* self, const ImVec2 p)
{
    return  ImRect_Contains_Vec2(self, p);
}

pragma(inline):
bool  ImRect_Contains(ImRect* self, const ImRect r)
{
    return  ImRect_Contains_Rect(self, r);
}

pragma(inline):
void  ImRect_Expand(ImRect* self, const float amount)
{
     ImRect_Expand_Float(self, amount);
}

pragma(inline):
void  ImRect_Expand(ImRect* self, const ImVec2 amount)
{
     ImRect_Expand_Vec2(self, amount);
}

pragma(inline):
ImRect*  ImRect_ImRect()
{
    return  ImRect_ImRect_Nil();
}

pragma(inline):
ImRect*  ImRect_ImRect(const ImVec2 min, const ImVec2 max)
{
    return  ImRect_ImRect_Vec2(min, max);
}

pragma(inline):
ImRect*  ImRect_ImRect(const ImVec4 v)
{
    return  ImRect_ImRect_Vec4(v);
}

pragma(inline):
ImRect*  ImRect_ImRect(float x1, float y1, float x2, float y2)
{
    return  ImRect_ImRect_Float(x1, y1, x2, y2);
}

pragma(inline):
ImTextureRef*  ImTextureRef_ImTextureRef()
{
    return  ImTextureRef_ImTextureRef_Nil();
}

pragma(inline):
ImTextureRef*  ImTextureRef_ImTextureRef(ImTextureID tex_id)
{
    return  ImTextureRef_ImTextureRef_TextureID(tex_id);
}

pragma(inline):
ImVec1*  ImVec1_ImVec1()
{
    return  ImVec1_ImVec1_Nil();
}

pragma(inline):
ImVec1*  ImVec1_ImVec1(float _x)
{
    return  ImVec1_ImVec1_Float(_x);
}

pragma(inline):
ImVec2*  ImVec2_ImVec2()
{
    return  ImVec2_ImVec2_Nil();
}

pragma(inline):
ImVec2*  ImVec2_ImVec2(float _x, float _y)
{
    return  ImVec2_ImVec2_Float(_x, _y);
}

pragma(inline):
ImVec2i*  ImVec2i_ImVec2i()
{
    return  ImVec2i_ImVec2i_Nil();
}

pragma(inline):
ImVec2i*  ImVec2i_ImVec2i(int _x, int _y)
{
    return  ImVec2i_ImVec2i_Int(_x, _y);
}

pragma(inline):
ImVec2ih*  ImVec2ih_ImVec2ih()
{
    return  ImVec2ih_ImVec2ih_Nil();
}

pragma(inline):
ImVec2ih*  ImVec2ih_ImVec2ih(short _x, short _y)
{
    return  ImVec2ih_ImVec2ih_short(_x, _y);
}

pragma(inline):
ImVec2ih*  ImVec2ih_ImVec2ih(const ImVec2 rhs)
{
    return  ImVec2ih_ImVec2ih_Vec2(rhs);
}

pragma(inline):
ImVec4*  ImVec4_ImVec4()
{
    return  ImVec4_ImVec4_Nil();
}

pragma(inline):
ImVec4*  ImVec4_ImVec4(float _x, float _y, float _z, float _w)
{
    return  ImVec4_ImVec4_Float(_x, _y, _z, _w);
}

pragma(inline):
bool  igBeginChild(const(char)* str_id, const ImVec2 size = ImVec2(0,0), ImGuiChildFlags child_flags = ImGuiChildFlags.None, ImGuiWindowFlags window_flags = ImGuiWindowFlags.None)
{
    return  igBeginChild_Str(str_id, size, child_flags, window_flags);
}

pragma(inline):
bool  igBeginChild(ImGuiID id, const ImVec2 size = ImVec2(0,0), ImGuiChildFlags child_flags = ImGuiChildFlags.None, ImGuiWindowFlags window_flags = ImGuiWindowFlags.None)
{
    return  igBeginChild_ID(id, size, child_flags, window_flags);
}

pragma(inline):
bool  igCheckboxFlags(const(char)* label, int* flags, int flags_value)
{
    return  igCheckboxFlags_IntPtr(label, flags, flags_value);
}

pragma(inline):
bool  igCheckboxFlags(const(char)* label, uint* flags, uint flags_value)
{
    return  igCheckboxFlags_UintPtr(label, flags, flags_value);
}

pragma(inline):
bool  igCheckboxFlags(const(char)* label, ImS64* flags, ImS64 flags_value)
{
    return  igCheckboxFlags_S64Ptr(label, flags, flags_value);
}

pragma(inline):
bool  igCheckboxFlags(const(char)* label, ImU64* flags, ImU64 flags_value)
{
    return  igCheckboxFlags_U64Ptr(label, flags, flags_value);
}

pragma(inline):
bool  igCollapsingHeader(const(char)* label, ImGuiTreeNodeFlags flags = ImGuiTreeNodeFlags.None)
{
    return  igCollapsingHeader_TreeNodeFlags(label, flags);
}

pragma(inline):
bool  igCollapsingHeader(const(char)* label, bool* p_visible, ImGuiTreeNodeFlags flags = ImGuiTreeNodeFlags.None)
{
    return  igCollapsingHeader_BoolPtr(label, p_visible, flags);
}

pragma(inline):
bool  igCombo(const(char)* label, int* current_item, const(char)** items, int items_count, int popup_max_height_in_items = -1)
{
    return  igCombo_Str_arr(label, current_item, items, items_count, popup_max_height_in_items);
}

pragma(inline):
bool  igCombo(const(char)* label, int* current_item, const(char)* items_separated_by_zeros, int popup_max_height_in_items = -1)
{
    return  igCombo_Str(label, current_item, items_separated_by_zeros, popup_max_height_in_items);
}

extern(C) alias igCombo_getter = const(char)* function(void* user_data,int idx);

pragma(inline):
bool  igCombo(const(char)* label, int* current_item, igCombo_getter getter, void* user_data, int items_count, int popup_max_height_in_items = -1)
{
    return  igCombo_FnStrPtr(label, current_item, getter, user_data, items_count, popup_max_height_in_items);
}

pragma(inline):
ImU32  igGetColorU32(ImGuiCol idx, float alpha_mul = 1.0f)
{
    return  igGetColorU32_Col(idx, alpha_mul);
}

pragma(inline):
ImU32  igGetColorU32(const ImVec4 col)
{
    return  igGetColorU32_Vec4(col);
}

pragma(inline):
ImU32  igGetColorU32(ImU32 col, float alpha_mul = 1.0f)
{
    return  igGetColorU32_U32(col, alpha_mul);
}

pragma(inline):
ImDrawList*  igGetForegroundDrawList(ImGuiViewport* viewport = null)
{
    return  igGetForegroundDrawList_ViewportPtr(viewport);
}

pragma(inline):
ImDrawList*  igGetForegroundDrawList(ImGuiWindow* window)
{
    return  igGetForegroundDrawList_WindowPtr(window);
}

pragma(inline):
ImGuiID  igGetID(const(char)* str_id)
{
    return  igGetID_Str(str_id);
}

pragma(inline):
ImGuiID  igGetID(const(char)* str_id_begin, const(char)* str_id_end)
{
    return  igGetID_StrStr(str_id_begin, str_id_end);
}

pragma(inline):
ImGuiID  igGetID(const void* ptr_id)
{
    return  igGetID_Ptr(ptr_id);
}

pragma(inline):
ImGuiID  igGetID(int int_id)
{
    return  igGetID_Int(int_id);
}

pragma(inline):
ImGuiID  igGetIDWithSeed(const(char)* str_id_begin, const(char)* str_id_end, ImGuiID seed)
{
    return  igGetIDWithSeed_Str(str_id_begin, str_id_end, seed);
}

pragma(inline):
ImGuiID  igGetIDWithSeed(int n, ImGuiID seed)
{
    return  igGetIDWithSeed_Int(n, seed);
}

pragma(inline):
ImGuiIO*  igGetIO()
{
    return  igGetIO_Nil();
}

pragma(inline):
ImGuiIO*  igGetIO(ImGuiContext* ctx)
{
    return  igGetIO_ContextPtr(ctx);
}

pragma(inline):
ImGuiKeyData*  igGetKeyData(ImGuiContext* ctx, ImGuiKey key)
{
    return  igGetKeyData_ContextPtr(ctx, key);
}

pragma(inline):
ImGuiKeyData*  igGetKeyData(ImGuiKey key)
{
    return  igGetKeyData_Key(key);
}

pragma(inline):
ImGuiPlatformIO*  igGetPlatformIO()
{
    return  igGetPlatformIO_Nil();
}

pragma(inline):
ImGuiPlatformIO*  igGetPlatformIO(ImGuiContext* ctx)
{
    return  igGetPlatformIO_ContextPtr(ctx);
}

pragma(inline):
int  igImAbs(int x)
{
    return  igImAbs_Int(x);
}

pragma(inline):
float  igImAbs(float x)
{
    return  igImAbs_Float(x);
}

pragma(inline):
double  igImAbs(double x)
{
    return  igImAbs_double(x);
}

pragma(inline):
float  igImFloor(float f)
{
    return  igImFloor_Float(f);
}

pragma(inline):
ImVec2  igImFloor(const ImVec2 v)
{
    return  igImFloor_Vec2(v);
}

pragma(inline):
bool  igImIsPowerOfTwo(int v)
{
    return  igImIsPowerOfTwo_Int(v);
}

pragma(inline):
bool  igImIsPowerOfTwo(ImU64 v)
{
    return  igImIsPowerOfTwo_U64(v);
}

pragma(inline):
float  igImLengthSqr(const ImVec2 lhs)
{
    return  igImLengthSqr_Vec2(lhs);
}

pragma(inline):
float  igImLengthSqr(const ImVec4 lhs)
{
    return  igImLengthSqr_Vec4(lhs);
}

pragma(inline):
ImVec2  igImLerp(const ImVec2 a, const ImVec2 b, float t)
{
    return  igImLerp_Vec2Float(a, b, t);
}

pragma(inline):
ImVec2  igImLerp(const ImVec2 a, const ImVec2 b, const ImVec2 t)
{
    return  igImLerp_Vec2Vec2(a, b, t);
}

pragma(inline):
ImVec4  igImLerp(const ImVec4 a, const ImVec4 b, float t)
{
    return  igImLerp_Vec4(a, b, t);
}

pragma(inline):
float  igImLog(float x)
{
    return  igImLog_Float(x);
}

pragma(inline):
double  igImLog(double x)
{
    return  igImLog_double(x);
}

pragma(inline):
float  igImPow(float x, float y)
{
    return  igImPow_Float(x, y);
}

pragma(inline):
double  igImPow(double x, double y)
{
    return  igImPow_double(x, y);
}

pragma(inline):
float  igImRsqrt(float x)
{
    return  igImRsqrt_Float(x);
}

pragma(inline):
double  igImRsqrt(double x)
{
    return  igImRsqrt_double(x);
}

pragma(inline):
float  igImSign(float x)
{
    return  igImSign_Float(x);
}

pragma(inline):
double  igImSign(double x)
{
    return  igImSign_double(x);
}

pragma(inline):
float  igImTrunc(float f)
{
    return  igImTrunc_Float(f);
}

pragma(inline):
ImVec2  igImTrunc(const ImVec2 v)
{
    return  igImTrunc_Vec2(v);
}

pragma(inline):
bool  igIsKeyChordPressed(ImGuiKeyChord key_chord)
{
    return  igIsKeyChordPressed_Nil(key_chord);
}

pragma(inline):
bool  igIsKeyChordPressed(ImGuiKeyChord key_chord, ImGuiInputFlags flags, ImGuiID owner_id = 0)
{
    return  igIsKeyChordPressed_InputFlags(key_chord, flags, owner_id);
}

pragma(inline):
bool  igIsKeyDown(ImGuiKey key)
{
    return  igIsKeyDown_Nil(key);
}

pragma(inline):
bool  igIsKeyDown(ImGuiKey key, ImGuiID owner_id)
{
    return  igIsKeyDown_ID(key, owner_id);
}

pragma(inline):
bool  igIsKeyPressed(ImGuiKey key, bool repeat = true)
{
    return  igIsKeyPressed_Bool(key, repeat);
}

pragma(inline):
bool  igIsKeyPressed(ImGuiKey key, ImGuiInputFlags flags, ImGuiID owner_id = 0)
{
    return  igIsKeyPressed_InputFlags(key, flags, owner_id);
}

pragma(inline):
bool  igIsKeyReleased(ImGuiKey key)
{
    return  igIsKeyReleased_Nil(key);
}

pragma(inline):
bool  igIsKeyReleased(ImGuiKey key, ImGuiID owner_id)
{
    return  igIsKeyReleased_ID(key, owner_id);
}

pragma(inline):
bool  igIsMouseClicked(ImGuiMouseButton button, bool repeat = false)
{
    return  igIsMouseClicked_Bool(button, repeat);
}

pragma(inline):
bool  igIsMouseClicked(ImGuiMouseButton button, ImGuiInputFlags flags, ImGuiID owner_id = 0)
{
    return  igIsMouseClicked_InputFlags(button, flags, owner_id);
}

pragma(inline):
bool  igIsMouseDoubleClicked(ImGuiMouseButton button)
{
    return  igIsMouseDoubleClicked_Nil(button);
}

pragma(inline):
bool  igIsMouseDoubleClicked(ImGuiMouseButton button, ImGuiID owner_id)
{
    return  igIsMouseDoubleClicked_ID(button, owner_id);
}

pragma(inline):
bool  igIsMouseDown(ImGuiMouseButton button)
{
    return  igIsMouseDown_Nil(button);
}

pragma(inline):
bool  igIsMouseDown(ImGuiMouseButton button, ImGuiID owner_id)
{
    return  igIsMouseDown_ID(button, owner_id);
}

pragma(inline):
bool  igIsMouseReleased(ImGuiMouseButton button)
{
    return  igIsMouseReleased_Nil(button);
}

pragma(inline):
bool  igIsMouseReleased(ImGuiMouseButton button, ImGuiID owner_id)
{
    return  igIsMouseReleased_ID(button, owner_id);
}

pragma(inline):
bool  igIsPopupOpen(const(char)* str_id, ImGuiPopupFlags flags = ImGuiPopupFlags.None)
{
    return  igIsPopupOpen_Str(str_id, flags);
}

pragma(inline):
bool  igIsPopupOpen(ImGuiID id, ImGuiPopupFlags popup_flags)
{
    return  igIsPopupOpen_ID(id, popup_flags);
}

pragma(inline):
bool  igIsRectVisible(const ImVec2 size)
{
    return  igIsRectVisible_Nil(size);
}

pragma(inline):
bool  igIsRectVisible(const ImVec2 rect_min, const ImVec2 rect_max)
{
    return  igIsRectVisible_Vec2(rect_min, rect_max);
}

pragma(inline):
void  igItemSize(const ImVec2 size, float text_baseline_y = -1.0f)
{
     igItemSize_Vec2(size, text_baseline_y);
}

pragma(inline):
void  igItemSize(const ImRect bb, float text_baseline_y = -1.0f)
{
     igItemSize_Rect(bb, text_baseline_y);
}

pragma(inline):
bool  igListBox(const(char)* label, int* current_item, const(char)** items, int items_count, int height_in_items = -1)
{
    return  igListBox_Str_arr(label, current_item, items, items_count, height_in_items);
}

extern(C) alias igListBox_getter = const(char)* function(void* user_data,int idx);

pragma(inline):
bool  igListBox(const(char)* label, int* current_item, igListBox_getter getter, void* user_data, int items_count, int height_in_items = -1)
{
    return  igListBox_FnStrPtr(label, current_item, getter, user_data, items_count, height_in_items);
}

pragma(inline):
void  igMarkIniSettingsDirty()
{
     igMarkIniSettingsDirty_Nil();
}

pragma(inline):
void  igMarkIniSettingsDirty(ImGuiWindow* window)
{
     igMarkIniSettingsDirty_WindowPtr(window);
}

pragma(inline):
bool  igMenuItem(const(char)* label, const(char)* shortcut = null, bool selected = false, bool enabled = true)
{
    return  igMenuItem_Bool(label, shortcut, selected, enabled);
}

pragma(inline):
bool  igMenuItem(const(char)* label, const(char)* shortcut, bool* p_selected, bool enabled = true)
{
    return  igMenuItem_BoolPtr(label, shortcut, p_selected, enabled);
}

pragma(inline):
bool  igOpenPopup(const(char)* str_id, ImGuiPopupFlags popup_flags = ImGuiPopupFlags.None)
{
    return  igOpenPopup_Str(str_id, popup_flags);
}

pragma(inline):
bool  igOpenPopup(ImGuiID id, ImGuiPopupFlags popup_flags = ImGuiPopupFlags.None)
{
    return  igOpenPopup_ID(id, popup_flags);
}

pragma(inline):
void  igPlotHistogram(const(char)* label, const float* values, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = float.max, float scale_max = float.max, ImVec2 graph_size = ImVec2(0,0), int stride = float.sizeof)
{
     igPlotHistogram_FloatPtr(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride);
}

extern(C) alias igPlotHistogram_values_getter = float function(void* data,int idx);

pragma(inline):
void  igPlotHistogram(const(char)* label, igPlotHistogram_values_getter values_getter, void* data, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = float.max, float scale_max = float.max, ImVec2 graph_size = ImVec2(0,0))
{
     igPlotHistogram_FnFloatPtr(label, values_getter, data, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size);
}

pragma(inline):
void  igPlotLines(const(char)* label, const float* values, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = float.max, float scale_max = float.max, ImVec2 graph_size = ImVec2(0,0), int stride = float.sizeof)
{
     igPlotLines_FloatPtr(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride);
}

extern(C) alias igPlotLines_values_getter = float function(void* data,int idx);

pragma(inline):
void  igPlotLines(const(char)* label, igPlotLines_values_getter values_getter, void* data, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = float.max, float scale_max = float.max, ImVec2 graph_size = ImVec2(0,0))
{
     igPlotLines_FnFloatPtr(label, values_getter, data, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size);
}

pragma(inline):
void  igPushID(const(char)* str_id)
{
     igPushID_Str(str_id);
}

pragma(inline):
void  igPushID(const(char)* str_id_begin, const(char)* str_id_end)
{
     igPushID_StrStr(str_id_begin, str_id_end);
}

pragma(inline):
void  igPushID(const void* ptr_id)
{
     igPushID_Ptr(ptr_id);
}

pragma(inline):
void  igPushID(int int_id)
{
     igPushID_Int(int_id);
}

pragma(inline):
void  igPushStyleColor(ImGuiCol idx, ImU32 col)
{
     igPushStyleColor_U32(idx, col);
}

pragma(inline):
void  igPushStyleColor(ImGuiCol idx, const ImVec4 col)
{
     igPushStyleColor_Vec4(idx, col);
}

pragma(inline):
void  igPushStyleVar(ImGuiStyleVar idx, float val)
{
     igPushStyleVar_Float(idx, val);
}

pragma(inline):
void  igPushStyleVar(ImGuiStyleVar idx, const ImVec2 val)
{
     igPushStyleVar_Vec2(idx, val);
}

pragma(inline):
bool  igRadioButton(const(char)* label, bool active)
{
    return  igRadioButton_Bool(label, active);
}

pragma(inline):
bool  igRadioButton(const(char)* label, int* v, int v_button)
{
    return  igRadioButton_IntPtr(label, v, v_button);
}

pragma(inline):
bool  igSelectable(const(char)* label, bool selected = false, ImGuiSelectableFlags flags = ImGuiSelectableFlags.None, const ImVec2 size = ImVec2(0,0))
{
    return  igSelectable_Bool(label, selected, flags, size);
}

pragma(inline):
bool  igSelectable(const(char)* label, bool* p_selected, ImGuiSelectableFlags flags = ImGuiSelectableFlags.None, const ImVec2 size = ImVec2(0,0))
{
    return  igSelectable_BoolPtr(label, p_selected, flags, size);
}

pragma(inline):
bool  igSetItemKeyOwner(ImGuiKey key)
{
    return  igSetItemKeyOwner_Nil(key);
}

pragma(inline):
bool  igSetItemKeyOwner(ImGuiKey key, ImGuiInputFlags flags)
{
    return  igSetItemKeyOwner_InputFlags(key, flags);
}

pragma(inline):
void  igSetScrollFromPosX(float local_x, float center_x_ratio = 0.5f)
{
     igSetScrollFromPosX_Float(local_x, center_x_ratio);
}

pragma(inline):
void  igSetScrollFromPosX(ImGuiWindow* window, float local_x, float center_x_ratio)
{
     igSetScrollFromPosX_WindowPtr(window, local_x, center_x_ratio);
}

pragma(inline):
void  igSetScrollFromPosY(float local_y, float center_y_ratio = 0.5f)
{
     igSetScrollFromPosY_Float(local_y, center_y_ratio);
}

pragma(inline):
void  igSetScrollFromPosY(ImGuiWindow* window, float local_y, float center_y_ratio)
{
     igSetScrollFromPosY_WindowPtr(window, local_y, center_y_ratio);
}

pragma(inline):
void  igSetScrollX(float scroll_x)
{
     igSetScrollX_Float(scroll_x);
}

pragma(inline):
void  igSetScrollX(ImGuiWindow* window, float scroll_x)
{
     igSetScrollX_WindowPtr(window, scroll_x);
}

pragma(inline):
void  igSetScrollY(float scroll_y)
{
     igSetScrollY_Float(scroll_y);
}

pragma(inline):
void  igSetScrollY(ImGuiWindow* window, float scroll_y)
{
     igSetScrollY_WindowPtr(window, scroll_y);
}

pragma(inline):
void  igSetWindowCollapsed(bool collapsed, ImGuiCond cond = ImGuiCond.None)
{
     igSetWindowCollapsed_Bool(collapsed, cond);
}

pragma(inline):
void  igSetWindowCollapsed(const(char)* name, bool collapsed, ImGuiCond cond = ImGuiCond.None)
{
     igSetWindowCollapsed_Str(name, collapsed, cond);
}

pragma(inline):
void  igSetWindowCollapsed(ImGuiWindow* window, bool collapsed, ImGuiCond cond = ImGuiCond.None)
{
     igSetWindowCollapsed_WindowPtr(window, collapsed, cond);
}

pragma(inline):
void  igSetWindowFocus()
{
     igSetWindowFocus_Nil();
}

pragma(inline):
void  igSetWindowFocus(const(char)* name)
{
     igSetWindowFocus_Str(name);
}

pragma(inline):
void  igSetWindowPos(const ImVec2 pos, ImGuiCond cond = ImGuiCond.None)
{
     igSetWindowPos_Vec2(pos, cond);
}

pragma(inline):
void  igSetWindowPos(const(char)* name, const ImVec2 pos, ImGuiCond cond = ImGuiCond.None)
{
     igSetWindowPos_Str(name, pos, cond);
}

pragma(inline):
void  igSetWindowPos(ImGuiWindow* window, const ImVec2 pos, ImGuiCond cond = ImGuiCond.None)
{
     igSetWindowPos_WindowPtr(window, pos, cond);
}

pragma(inline):
void  igSetWindowSize(const ImVec2 size, ImGuiCond cond = ImGuiCond.None)
{
     igSetWindowSize_Vec2(size, cond);
}

pragma(inline):
void  igSetWindowSize(const(char)* name, const ImVec2 size, ImGuiCond cond = ImGuiCond.None)
{
     igSetWindowSize_Str(name, size, cond);
}

pragma(inline):
void  igSetWindowSize(ImGuiWindow* window, const ImVec2 size, ImGuiCond cond = ImGuiCond.None)
{
     igSetWindowSize_WindowPtr(window, size, cond);
}

pragma(inline):
bool  igShortcut(ImGuiKeyChord key_chord, ImGuiInputFlags flags = ImGuiInputFlags.None)
{
    return  igShortcut_Nil(key_chord, flags);
}

pragma(inline):
bool  igShortcut(ImGuiKeyChord key_chord, ImGuiInputFlags flags, ImGuiID owner_id)
{
    return  igShortcut_ID(key_chord, flags, owner_id);
}

pragma(inline):
void  igTabBarQueueFocus(ImGuiTabBar* tab_bar, ImGuiTabItem* tab)
{
     igTabBarQueueFocus_TabItemPtr(tab_bar, tab);
}

pragma(inline):
void  igTabBarQueueFocus(ImGuiTabBar* tab_bar, const(char)* tab_name)
{
     igTabBarQueueFocus_Str(tab_bar, tab_name);
}

pragma(inline):
ImVec2  igTabItemCalcSize(const(char)* label, bool has_close_button_or_unsaved_marker)
{
    return  igTabItemCalcSize_Str(label, has_close_button_or_unsaved_marker);
}

pragma(inline):
ImVec2  igTabItemCalcSize(ImGuiWindow* window)
{
    return  igTabItemCalcSize_WindowPtr(window);
}

pragma(inline):
void  igTableGcCompactTransientBuffers(ImGuiTable* table)
{
     igTableGcCompactTransientBuffers_TablePtr(table);
}

pragma(inline):
void  igTableGcCompactTransientBuffers(ImGuiTableTempData* table)
{
     igTableGcCompactTransientBuffers_TableTempDataPtr(table);
}

pragma(inline):
const(char)*  igTableGetColumnName(int column_n = -1)
{
    return  igTableGetColumnName_Int(column_n);
}

pragma(inline):
const(char)*  igTableGetColumnName(const ImGuiTable* table, int column_n)
{
    return  igTableGetColumnName_TablePtr(table, column_n);
}

pragma(inline):
bool  igTreeNode(const(char)* label)
{
    return  igTreeNode_Str(label);
}

pragma(inline):
bool  igTreeNode(const(char)* str_id, const(char)* fmt, ...)
{
    return  igTreeNode_StrStr(str_id, fmt);
}

pragma(inline):
bool  igTreeNode(const void* ptr_id, const(char)* fmt, ...)
{
    return  igTreeNode_Ptr(ptr_id, fmt);
}

pragma(inline):
bool  igTreeNodeEx(const(char)* label, ImGuiTreeNodeFlags flags = ImGuiTreeNodeFlags.None)
{
    return  igTreeNodeEx_Str(label, flags);
}

pragma(inline):
bool  igTreeNodeEx(const(char)* str_id, ImGuiTreeNodeFlags flags, const(char)* fmt, ...)
{
    return  igTreeNodeEx_StrStr(str_id, flags, fmt);
}

pragma(inline):
bool  igTreeNodeEx(const void* ptr_id, ImGuiTreeNodeFlags flags, const(char)* fmt, ...)
{
    return  igTreeNodeEx_Ptr(ptr_id, flags, fmt);
}

pragma(inline):
bool  igTreeNodeExV(const(char)* str_id, ImGuiTreeNodeFlags flags, const(char)* fmt, va_list args)
{
    return  igTreeNodeExV_Str(str_id, flags, fmt, args);
}

pragma(inline):
bool  igTreeNodeExV(const void* ptr_id, ImGuiTreeNodeFlags flags, const(char)* fmt, va_list args)
{
    return  igTreeNodeExV_Ptr(ptr_id, flags, fmt, args);
}

pragma(inline):
bool  igTreeNodeV(const(char)* str_id, const(char)* fmt, va_list args)
{
    return  igTreeNodeV_Str(str_id, fmt, args);
}

pragma(inline):
bool  igTreeNodeV(const void* ptr_id, const(char)* fmt, va_list args)
{
    return  igTreeNodeV_Ptr(ptr_id, fmt, args);
}

pragma(inline):
void  igTreePush(const(char)* str_id)
{
     igTreePush_Str(str_id);
}

pragma(inline):
void  igTreePush(const void* ptr_id)
{
     igTreePush_Ptr(ptr_id);
}

pragma(inline):
void  igValue(const(char)* prefix, bool b)
{
     igValue_Bool(prefix, b);
}

pragma(inline):
void  igValue(const(char)* prefix, int v)
{
     igValue_Int(prefix, v);
}

pragma(inline):
void  igValue(const(char)* prefix, uint v)
{
     igValue_Uint(prefix, v);
}

pragma(inline):
void  igValue(const(char)* prefix, float v, const(char)* float_format = null)
{
     igValue_Float(prefix, v, float_format);
}

