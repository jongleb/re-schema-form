open MutualTypes

module rec SchemaRenderImpl: SchemaRender = SchemaRender.Make(SwitchRenderImpl)
and ReRenderImpl: ReRender = ReRender.Make(SchemaRenderImpl)
and SwitchRenderImpl: SwitchRender = SwitchRender.Make(
  ObjectRenderImpl,
  ArrayRenderImpl,
  NullableRenderImpl,
)
and ObjectRenderImpl: ObjectRender = ObjectRender.Make(ReRenderImpl)
and ArrayRenderImpl: ArrayRender = ArrayRender.Make(SchemaRenderImpl)
and NullableRenderImpl: NullableRender = NullableRender.Make(SchemaRenderImpl)
