import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CourseComment extends StatefulWidget {
  const CourseComment({super.key});

  @override
  State<CourseComment> createState() => _CourseCommentState();
}

class _CourseCommentState extends State<CourseComment> {
  bool iconOn = false;
  bool isExpanded = false;
  final String fullText =
      'The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitias dixit parab les esseaaaaaaaaaaaaaaaaaaaaaaaaspppppppppppppppppppppppppppppppppppppppppppppppppppppsssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss';
  @override
  Widget build(BuildContext context) {
    bool shouldShowSeeAll = fullText.length > 131;
    String displayedText = isExpanded
        ? fullText
        : (shouldShowSeeAll ? '${fullText.substring(0, 120)}...' : fullText);

    // Estimate number of lines based on text length (40 characters per line)
    int lineCount = (displayedText.length / 40).ceil();

    // Calculate dynamic height (each line ~18 pixels)
    double textHeight = lineCount * 18.0;
    double baseHeight = 120; // Base height without text
    double totalHeight = baseHeight + textHeight;

    return Container(
      height: totalHeight,
      width: 360,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.withOpacity(0.2),
              radius: 23,
              child: Image.asset(
                'assets/images/ProfilePic.png',
                height: 30,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(
                height: 19,
              ),
              Transform(
                transform: Matrix4.translationValues(-12, 0, 0),
                child: Row(
                  children: [
                    const Text(
                      'Ahmed Mohamed',
                      style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 57,
                    ),
                    Container(
                      height: 26,
                      width: 55,
                      decoration: BoxDecoration(
                          color: const Color(0xffE8F1FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xff4D81E5), width: 2)),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 4,
                          ),
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 17,
                          ),
                          Text(
                            '4.2',
                            style: TextStyle(
                                fontFamily: 'Jost',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff202244)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: 275,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayedText,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff545454),
                      ),
                    ),
                    if (shouldShowSeeAll) // Show "See All" / "See Less" only if needed
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Text(
                          isExpanded ? 'See Less' : 'See All',
                          style: const TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Transform.translate(
                offset: const Offset(-50, 0),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            iconOn = !iconOn;
                          });
                        },
                        icon: iconOn
                            ? const Icon(
                                CupertinoIcons.heart_fill,
                                color: Color(0xffDD2E44),
                                size: 23,
                              )
                            : const Icon(
                                CupertinoIcons.heart,
                                color: Color(0xff1D1D1B),
                                size: 23,
                              )),
                    const Text(
                      '760',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Mulish',
                          fontSize: 14,
                          color: Color(0xff202244)),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    const SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        color: Colors.black,
                        thickness: 1.2,
                        width: 20,
                      ),
                    ),
                    const Text(
                      '2 Weeks Ago',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Mulish',
                          fontSize: 14,
                          color: Color(0xff202244)),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
