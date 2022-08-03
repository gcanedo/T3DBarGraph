unit U3DBarGraph;

interface
  uses
    FMX.Viewport3D, System.Classes;

  type
    T3DBarGraph = class(TViewport3D)
      private
      protected
      public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
      published

    end;

implementation

constructor T3DBarGraph.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor T3DBarGraph.Destroy;
begin
  inherited;
end;


end.
