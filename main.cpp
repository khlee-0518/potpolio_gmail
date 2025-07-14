#include <opencv2/highgui.hpp>
#include <iostream>
#include <opencv2/imgproc.hpp> // cv::putText() ����� ����

using namespace std;
using namespace cv;


int main()
{
    Mat img_input, img_gray, img_result;

    //�̹��� ������ �о�ͼ� img_input�� ����
    img_input = imread("turtle_gauss.jpg", IMREAD_COLOR);
//    img_input = imread("money.jpg", IMREAD_COLOR);
    if (img_input.empty())
    {
        cout << "������ �о�ü� �����ϴ�." << endl;
        exit(1);
    }


    //�Է¿����� �׷��̽����� �������� ��ȯ
    img_gray = Mat(img_input.rows, img_input.cols, CV_8UC1);

    for (int y = 0; y < img_input.rows; y++)
    {
        for (int x = 0; x < img_input.cols; x++)
        {
            //img_input���κ��� ���� ��ġ (y,x) �ȼ���
            //blue, green, red ���� �о�´�. 
            uchar blue = img_input.at<Vec3b>(y, x)[0];
            uchar green = img_input.at<Vec3b>(y, x)[1];
            uchar red = img_input.at<Vec3b>(y, x)[2];

            //blue, green, red�� ���� ��, 3���� ������ �׷��̽������� �ȴ�.
            uchar gray = (blue + green + red) / 3.0;

            //MatŸ�� ���� img_gray�� �����Ѵ�. 
            img_gray.at<uchar>(y, x) = gray;
        }
    }


    //mean mask]
    int k=1;
    int mask1_gauss[3][3]   = { { 1, 2, 1 },
                                { 2, 4, 2 },
                                { 1, 2, 1 } };
    int mask1_lap[3][3]     = { { 1, 1, 1},
                                { 1,-8, 1 },
                                { 1, 1, 1 } };
    int mask1_sobel_x[3][3] = { { 1, 2, 1 },
                                { 0, 0, 0 },
                                {-1,-2,-1 } };
    int mask1_sobel_y[3][3] = { {-1, 0, 1 },
                                {-2, 0, 2 },
                                {-1, 0, 1 } };
    int mask2_gauss[5][5]   = { { 1, 4, 6, 4, 1 },
                                { 4,16,24,16, 4 },
                                { 6,24,36,24, 6 },
                                { 4,16,24,16, 4 },
                                { 1, 4, 6, 4,1 } };
//    int mask2_lap[5][5]     = { { 0, 0,  1, 0, 0 },
//                                { 0, 1,  2, 1, 0 },
//                                { 1, 2,-16, 2, 1 },
//                                { 0, 1,  2, 1, 0 },
//                                { 0, 0,  1, 0, 0 } };
    int mask2_lap[5][5]     = { { k * 0, k * 0, k *  1, k * 0, k * 0 },
                                { k * 0, k * 1, k *  2, k * 1, k * 0 },
                                { k * 1, k * 2, k *-16, k * 2, k * 1 },
                                { k * 0, k * 1, k *  2, k * 1, k * 0 },
                                { k * 0, k * 0, k *  1, k * 0, k * 0 } };
//    int mask2_sobel_x[5][5] = { { 1, 1, 2, 1, 1 },
//                                { 1, 1, 2, 1, 1 },
//                                { 0, 0, 0, 0, 0 },
//                                {-1,-1,-2,-1,-1 },
//                                {-1,-1,-2,-1,-1 } };
    int mask2_sobel_x[5][5] = { { k * 1, k * 1, k * 2, k * 1, k * 1 },
                                { k * 1, k * 1, k * 2, k * 1, k * 1 },
                                { k * 0, k * 0, k * 0, k * 0, k * 0 },
                                { k *-1, k *-1, k *-2, k *-1, k *-1 },
                                { k *-1, k *-1, k *-2, k *-1, k *-1 } };
//    int mask2_sobel_y[5][5] = { {-1,-1, 0, 1, 1 },
//                                {-1,-1, 0, 1, 1 },
//                                {-2,-2, 0, 2, 2 },
//                                {-1,-1, 0, 1, 1 },
//                                {-1,-1, 0, 1, 1 } };
    int mask2_sobel_y[5][5] = { { k *-1, k *-1, k * 0, k * 1, k * 1 },
                                { k *-1, k *-1, k * 0, k * 1, k * 1 },
                                { k *-2, k *-2, k * 0, k * 2, k * 2 },
                                { k *-1, k *-1, k * 0, k * 1, k * 1 },
                                { k *-1, k *-1, k * 0, k * 1, k * 1 } };

    long int sum;
    long int sum_x;
    long int sum_y;
    img_result = Mat(img_input.rows, img_input.cols, CV_8UC1);
    int masksize = 5;
//    int masksize = 3;
//  int filter = 2;//gauccian
//    int filter = 1;//laplacian
//  int filter = 2;//sobel
  for (int filter = 0; filter < 4; filter++)
  {
      for (int y = 0; y < img_input.rows; y++)
      {
          for (int x = 0; x < img_input.cols; x++)
          {
              sum = 0;
              sum_x = 0;
              sum_y = 0;
              for (int i = -1 * masksize / 2; i <= masksize / 2; i++)
              {
                  for (int j = -1 * masksize / 2; j <= masksize / 2; j++)
                  {


                      //���� ������ ��� ��� �׵θ� ���� ��� 
                      int new_y = y + i;
                      int new_x = x + j;

                      if (new_y < 0) new_y = 0;
                      else if (new_y > img_input.rows - 1) new_y = img_input.rows - 1;

                      if (new_x < 0) new_x = 0;
                      else if (new_x > img_input.cols - 1) new_x = img_input.cols - 1;


                      //������ ����ũ ũ�� ���� ������� ���
                      if (filter == 0) {
                          if (masksize == 3)
                              sum += img_gray.at<uchar>(new_y, new_x) * mask1_gauss[masksize / 2 + i][masksize / 2 + j];
                          else if (masksize == 5)
                              sum += img_gray.at<uchar>(new_y, new_x) * mask2_gauss[masksize / 2 + i][masksize / 2 + j];
                      }
                      if (filter == 1) {
                          if (masksize == 3)
                              sum += img_gray.at<uchar>(new_y, new_x) * mask1_lap[masksize / 2 + i][masksize / 2 + j];
                          else if (masksize == 5)
                              sum += img_gray.at<uchar>(new_y, new_x) * mask2_lap[masksize / 2 + i][masksize / 2 + j];
                      }
                      if (filter == 2) {
                          if (masksize == 3) {
                              sum_x += img_gray.at<uchar>(new_y, new_x) * mask1_sobel_x[masksize / 2 + i][masksize / 2 + j];
                              sum_y += img_gray.at<uchar>(new_y, new_x) * mask1_sobel_y[masksize / 2 + i][masksize / 2 + j];
                          }
                          else if (masksize == 5) {
                              sum_x += img_gray.at<uchar>(new_y, new_x) * mask2_sobel_x[masksize / 2 + i][masksize / 2 + j];
                              sum_y += img_gray.at<uchar>(new_y, new_x) * mask2_sobel_y[masksize / 2 + i][masksize / 2 + j];
                          }
                      }
                      if (filter == 3) {
                          if (masksize == 3) {
                              sum_x += img_gray.at<uchar>(new_y, new_x) * mask1_sobel_x[masksize / 2 + i][masksize / 2 + j];
                              sum_y += img_gray.at<uchar>(new_y, new_x) * mask1_sobel_y[masksize / 2 + i][masksize / 2 + j];
                          }
                          else if (masksize == 5) {
                              sum_x += img_gray.at<uchar>(new_y, new_x) * mask2_sobel_x[masksize / 2 + i][masksize / 2 + j];
                              sum_y += img_gray.at<uchar>(new_y, new_x) * mask2_sobel_y[masksize / 2 + i][masksize / 2 + j];
                          }
                      }
                  }
              }

              //����ũ ũ��� ������ �־�� �Ѵ�. 
              //sum = sum / (double)(masksize * masksize);
              if (filter == 0) {
                  if (masksize == 3)
                      sum = sum / 16;
                  else if (masksize == 5)
                      sum = sum / 256;
              }
              else if (filter == 1) {
                  sum = sum;
              }
              else if (filter == 2) {
                  if (masksize == 3)
                      sum = (sum_x + sum_y) / 1;
                  else if (masksize == 5)
                      //sum = (sum_x + sum_y) / 2;
                      sum = sqrt(sum_x * sum_x + sum_y * sum_y);
              }
              else if (filter == 3) {
                     if (sum_x >= 255) sum_x = 255;
                     if (sum_x < 0) sum_x = -sum_x;          
//                      if (sum_x <= 0) sum_x = 0;

                      if (sum_y >= 255) sum_y = 255;
                      if (sum_y < 0) sum_y = -sum_y;
//                      if (sum_y <= 0) sum_y = 0;

                      sum = (sum_x + sum_y) / 1.4 ;

                      //sum = ( abs(sum_x) + abs(sum_y) ) / 2;
                      //sum = sqrt(sum_x*sum_x+ sum_y * sum_y);
              }

//              if (sum_x > 255) sum_x = 0;
//              if (sum_y > 255) sum_y = 0;
//              sum = (sum_x + sum_y) / 1.4 ;
              
              //0~255 ���̰����� ����
              if (sum > 255) sum = 255;
//              if (sum < 0) sum = 0;
//              sum = sum / 2;
              img_result.at<uchar>(y, x) = sum;
          }
      }


      //ȭ�鿡 ��� �̹����� �����ش�.
//      imshow("�Է� ����", img_input);
//      imshow("�Է� �׷��̽����� ����", img_gray);
//      imshow("��� ����", img_result);

      //�ƹ�Ű�� ������ ������ ���
//      int flag;
//        flag=getchar();

      //����� ���Ϸ� ����
  //    imwrite("img_gray.jpg", img_gray);
      if (filter == 0) {
          //putText(����, �ؽ�Ʈ, ��ǥ, ��Ʈ, ����ũ��, �÷�, ����Ÿ��, )
          putText(img_result, "opencv_gaussian", Point(700, 150), 4, 1, Scalar(255, 255, 255), 0, 8);
          imwrite("img_result_gauss.jpg", img_result);
      }
      else if (filter == 1) {
          putText(img_result, "opencv_laplacian", Point(700, 150), 4, 1, Scalar(255, 255, 255), 0, 8);
          imwrite("img_result_lapl.jpg", img_result);
      }
      else if (filter == 2) {
          putText(img_result, "opencv_sobel_sqrt", Point(700, 150), 4, 1, Scalar(255, 255, 255), 0, 8);
          imwrite("img_result_sobel.jpg", img_result);
      }
      else if (filter == 3) {
          putText(img_result, "opencv_sobel_aprx", Point(700, 150), 4, 1, Scalar(255, 255, 255), 0, 8);
          imwrite("img_result_sobel_aprx.jpg", img_result);
      }
  }
}
