class Transaction {
  final String title;
  final String category;
  final String imageUrl;
  final String status;

  Transaction(
      {required this.title,
      required this.category,
      required this.imageUrl,
      required this.status});
}

List<Transaction> transactions = [
  Transaction(
      title: "Build Personal Branding",
      category: "Web Designer",
      imageUrl: "assets/image1.png",
      status: "Paid"),
  Transaction(
      title: "Mastering Blender 3D",
      category: "UI/UX Designer",
      imageUrl: "assets/image2.png",
      status: "Paid"),
  Transaction(
      title: "Full Stack Web Development",
      category: "Web Development",
      imageUrl: "assets/image3.png",
      status: "Paid"),
  Transaction(
      title: "Complete UI Designer",
      category: "HR Management",
      imageUrl: "assets/image4.png",
      status: "Paid"),
  Transaction(
      title: "Sharing Work with Team",
      category: "Finance & Accounting",
      imageUrl: "assets/image5.png",
      status: "Paid"),
];
