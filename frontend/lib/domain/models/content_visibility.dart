enum ContentVisibility {
  public('Pubblico', 'Visibile nel catalogo istituzionale'),
  restricted('Limitato', 'Solo tramite link condiviso'),
  private('Privato', 'Visibile solo a te');

  const ContentVisibility(this.label, this.description);

  final String label;
  final String description;
}
