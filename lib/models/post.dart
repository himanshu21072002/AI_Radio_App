class Post {
  int? id;
  String? name;
  String? tagline;
  String? color;
  String? desc;
  String? url;
  String? icon;
  String? image;
  String? lang;
  int? orders;
  String? category;

  Post(
      {this.id,
        this.name,
        this.tagline,
        this.color,
        this.desc,
        this.url,
        this.icon,
        this.image,
        this.lang,
        this.orders,
        this.category});

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    tagline = json['tagline'];
    color = json['color'];
    desc = json['desc'];
    url = json['url'];
    icon = json['icon'];
    image = json['image'];
    lang = json['lang'];
    orders = json['orders'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['tagline'] = this.tagline;
    data['color'] = this.color;
    data['desc'] = this.desc;
    data['url'] = this.url;
    data['icon'] = this.icon;
    data['image'] = this.image;
    data['lang'] = this.lang;
    data['orders'] = this.orders;
    data['category'] = this.category;
    return data;
  }
}