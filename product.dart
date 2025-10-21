class Product{
    final int idProduct;
    final String namaProduct;
    final int hargaProduct;
    final String desc;
    final String urlImage;

    Product({this.idProduct, this.namaProduct, this.hargaProduct, this.desc, this.urlImage});

    Map<String,dynamic> toMap(){
      return{
          'id' : idProduct,
          'nama' : namaProduct,
          'harga' : hargaProduct,
          'desc' : desc,
          'urlImg' : urlImage
      };
    }
    @override
  String toString() {
    return "Dog{id: $idProduct, name: $namaProduct, harga: $hargaProduct, desc: $desc, urlImg: $urlImage}";
  }
}