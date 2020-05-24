//
//  AUScanline.m
//  AuraU
//
//  Created by Thundersoft on 15/3/13.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUScanline.h"
#include "opencv2/opencv.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/highgui/highgui_c.h"

#define SHOWING_RESULT  0

static int calcOrientation(IplImage *img, CvBox2D* box)
{
    CvMoments moments;
    double m00 = 0, m10, m01, mu20, mu11, mu02, inv_m00;
    double a, b, c, xc, yc;
    double rotate_a, rotate_c;
    double theta = 0, square;
    double cs, sn;
    double length = 0, width = 0;
    //int itersUsed = 0;

    int count = cvCountNonZero(img);

    if ( count < (img->width*img->height*0.08) || count > (img->width*img->height*0.7) )
        return 0;

    cvMoments( img, &moments );

    m00 = moments.m00;
    m10 = moments.m10;
    m01 = moments.m01;
    mu11 = moments.mu11;
    mu20 = moments.mu20;
    mu02 = moments.mu02;

    if( fabs(m00) < DBL_EPSILON )
        return 0;

    inv_m00 = 1. / m00;
    xc = cvRound( m10 * inv_m00 );
    yc = cvRound( m01 * inv_m00 );
    a = mu20 * inv_m00;
    b = mu11 * inv_m00;
    c = mu02 * inv_m00;

    /* Calculating width & height */
    square = sqrt( 4 * b * b + (a - c) * (a - c) );

    /* Calculating orientation */
    theta = atan2( 2 * b, a - c + square );

    /* Calculating width & length */
    cs = cos( theta );
    sn = sin( theta );

    rotate_a = cs * cs * mu20 + 2 * cs * sn * mu11 + sn * sn * mu02;
    rotate_c = sn * sn * mu20 - 2 * cs * sn * mu11 + cs * cs * mu02;
    length = sqrt( rotate_a * inv_m00 ) * 4;
    width  = sqrt( rotate_c * inv_m00 ) * 4;

    if( length < width )
    {
        double t;

        CV_SWAP( length, width, t );
        CV_SWAP( cs, sn, t );
        theta = CV_PI*0.5 - theta;
    }

    if(length < 1.2*width)
        return 0;


    if( box )
    {
        box->size.height = (float)length;
        box->size.width = (float)width;
        box->angle = (float)(theta*180./CV_PI);
        box->center = cvPoint2D32f( xc, yc );
    }

#if SHOWING_RESULT
    CvPoint p1, p2;
    p1.x = cvRound( xc - 0.5 * length*cs );
    p1.y = cvRound( yc - 0.5 * length*sn );
    p2.x = cvRound( xc + 0.5 * length*cs );
    p2.y = cvRound( yc + 0.5 * length*sn );


    IplImage *img1 = cvCreateImage(cvGetSize(img),8,3);
    //	cvRectangle(img1, p1, p2, cvScalar(255, 255, 0), 3);
    cvLine(img1, p1, p2, cvScalar(255, 255, 0), 3);
    cvShowImage("",img1);
    cvReleaseImage(&img1);
#endif

    return 1;

}



static int DecodeAngle( CvBox2D& box1, CvBox2D& box2, int code, float& angle, int& direction, int img_width )
{
    const int coor_x1 = 0;
    const int coor_y1 = 0;
    const int coor_x2 = img_width  /*176*/;
    const int coor_y2 = 0;

    float xc_p = 0.0, yc_p = 0.0, xc_w = 0.0, yc_w = 0.0;

    xc_p  = box1.center.x;
    yc_p  = box1.center.y;
    xc_w  = box2.center.x;
    yc_w  = box2.center.y;

    if( (box1.size.height/box1.size.width) > (box2.size.height/box2.size.width) )
        angle = box1.angle;
    else
        angle = box2.angle;


    float dist1 = abs(xc_w - coor_x1) + abs(yc_w-coor_y1);
    float dist2 = abs(xc_p - coor_x1) + abs(yc_p-coor_y1);

    float dist3 = abs(xc_w - coor_x2) + abs(yc_w-coor_y2);
    float dist4 = abs(xc_p - coor_x2) + abs(yc_p-coor_y2);

    if( angle <= 0 )
    {
        if( dist1 < dist2 )
            direction = 1;
        else
            direction = -1;
    }

    if( angle > 0 )
    {
        if( dist3 < dist4 )
            direction = 1;
        else
            direction = -1;
    }

    return 1;

}


static int Otsu(IplImage* src, IplImage*dst = NULL)  //dst√ª”–∏≥÷µ£¨
{
    int width=src->width;
    int height=src->height;
    //long N = width * height;
    int h[256] ={0};//÷±∑ΩÕº£¨π≤256∏ˆµ„
    double sum=0.0,csum=0.0,m1,m2,fmax=-1.0,sb;    //sbŒ™¿‡º‰∑Ω≤Ó£¨fmax¥Ê¥¢◊Ó¥Û∑Ω≤Ó÷µ
    int n=0,n1=0,n2=0,threshValue = 1;

    for(int i = 0; i < height; i++)
    {
        for(int j = 0; j < width; j++)
        {
            int k1=((uchar*)(src->imageData + src->widthStep*i))[j];
            h[k1]++;
        }
    }

    for(int k = 0; k < 256; k++)
    {
        sum+= (double)k*(double)h[k];//÷ ¡øæÿ
        n+=h[k];//ÕºœÒµƒ◊‹µ„ ˝
    }
    for(int k=0;k<256;k++)
    {
        n1+=h[k];
        if(n1==0) continue;
        n2=n-n1;   //±≥æ∞µ„ ˝
        if(n2==0) break;
        csum += (double)k * h[k];    //«∞æ∞µƒ°∞ª“∂»µƒ÷µ*∆‰µ„ ˝°±µƒ◊‹∫Õ
        m1 = csum / n1;                     //m1Œ™«∞æ∞µƒ∆Ωæ˘ª“∂»
        m2 = (sum - csum) / n2;               //m2Œ™±≥æ∞µƒ∆Ωæ˘ª“∂»
        sb = (double)n1 * (double)n2 * (m1 - m2) * (m1 - m2);   //sbŒ™¿‡º‰∑Ω≤Ó
        if (sb > fmax)                  //»Áπ˚À„≥ˆµƒ¿‡º‰∑Ω≤Ó¥Û”⁄«∞“ª¥ŒÀ„≥ˆµƒ¿‡º‰∑Ω≤Ó
        {
            fmax = sb;                    //fmax º÷’Œ™◊Ó¥Û¿‡º‰∑Ω≤Ó£®otsu£©
            threshValue = k;              //»°◊Ó¥Û¿‡º‰∑Ω≤Ó ±∂‘”¶µƒª“∂»µƒkæÕ «◊Óº—„–÷µ
        }
    }

    /*
     for(int i = 0; i < height; i++)
     {
     for(int j = 0; j < width; j++)
     {
     if(((uchar*)(src->imageData + src->widthStep*i))[j] > threshValue)
     ((uchar*)(dst->imageData + dst->widthStep*i))[j] = 255;
     else
     ((uchar*)(dst->imageData + dst->widthStep*i))[j] = 0;
     }
     }
     */
    return threshValue;
}


/****************************************************/
//  purple->1   blue->2   red->3   yellow->4
/****************************************************/

static int classifyStreak(IplImage *img, int& code, float& angle, int& direction)
{
    IplImage *imgr, *imgb, *imgy, *imgp, *hsv, *imgv/*, *imgs*/;
    //int xc = 0, yc = 0;
    int width  = img->width;
    int height = img->height;
    int pixnum = img->width*img->height;
    int threshold_s = THRESHOLD_S;
    int threshold_v = THRESHOLD_V;

    imgr = cvCreateImage(cvGetSize(img),8,1);
    imgb = cvCreateImage(cvGetSize(img),8,1);
    imgp = cvCreateImage(cvGetSize(img),8,1);
    imgy = cvCreateImage(cvGetSize(img),8,1);
    imgv = cvCreateImage(cvGetSize(img),8,1);
    //	imgs = cvCreateImage(cvGetSize(img),8,1);
    hsv  = cvCreateImage(cvGetSize(img),8,3);

    cvCvtColor(img, hsv, CV_BGR2HSV);
    cvSplit(hsv, NULL, NULL, imgv, NULL);
    //	cvSplit(hsv, NULL, imgs, imgv, NULL);

    int bFrameMode = 0;
    //	CvScalar avg_hsv = cvAvg(hsv);
    //	int avg_h = avg_hsv.val[0];
    //	int avg_s = avg_hsv.val[1];
    //	int avg_v = avg_hsv.val[2];

    //#if OTSU_TRRESHOLD
    int adpt = Otsu(imgv, NULL);
    // 	threshold_v = adpt*1.3+15;
    // 	if(adpt<30)
    // 		adpt = 30;
    threshold_v = adpt*1.2+40;
    if(threshold_v>130)
        threshold_v = 130;
    if(adpt>150)
    {
        bFrameMode = 1;
        threshold_s = threshold_s*0.75;
    }
    //#endif
    //
    cvZero(imgr);
    cvZero(imgb);
    cvZero(imgy);
    cvZero(imgp);

    int count[4];
    for(int k=0; k<4; k++)
        count[k] = 0;

    for(int i=0; i<height; i++)
    {
        for(int j=0; j<width; j++)
        {
            int hue, sat, val;
            hue = *(unsigned char*)(hsv->imageData + i*hsv->widthStep + 3*j);
            sat = *(unsigned char*)(hsv->imageData + i*hsv->widthStep + 3*j + 1);
            val = *(unsigned char*)(hsv->imageData + i*hsv->widthStep + 3*j + 2);

            if(hue>126&&hue<169&&sat>threshold_s*0.75&&val>threshold_v)  //purple
            {
                *((unsigned char*)imgp->imageData + i*imgp->widthStep + j) = 255;
                count[0]++;
            }
            else if(hue>97&&hue<126&&sat>threshold_s&&val>threshold_v)  //blue (hue>85&&hue<170)
            {
                //				*((unsigned char*)imgw->imageData + i*imgw->widthStep + j) = 255;
                *((unsigned char*)imgb->imageData + i*imgb->widthStep + j) = 255;
                count[1]++;
            }
            else if((hue<12||hue>170)&&sat>threshold_s&&val>threshold_v)   //red
            {
                *((unsigned char*)imgr->imageData + i*imgr->widthStep + j) = 255;
                count[2]++;
            }
            else if(hue>18&&hue<45&&sat>threshold_s&&val>threshold_v)    //(sat<30&&val>170)  //yellow
            {
                *((unsigned char*)imgy->imageData + i*imgy->widthStep + j) = 255;
                count[3]++;
            }
            else if(hue>11&&hue<19&&sat>threshold_s&&val>threshold_v)   //orange -> red or yellow
            {
                if(bFrameMode == 1)
                {
                    *((unsigned char*)imgr->imageData + i*imgr->widthStep + j) = 255;
                    count[2]++;
                }
                if(bFrameMode == 0 && val>threshold_v*1.1)  //hue>15
                {
                    *((unsigned char*)imgy->imageData + i*imgy->widthStep + j) = 255;
                    count[3]++;
                }
            }
            else
            {}
        }
    }

    CvBox2D box;
    box.angle = 0;

    //	static int calcOrientation(IplImage *img, CvBox2D* box)
    //	const int max_streak_len = 10;
    static CvBox2D boxes1[5];
    static CvBox2D boxes2[5];
    static CvBox2D boxes3[5];
    static CvBox2D boxes4[5];

    static int streak_len1 = 0;
    static int streak_len2 = 0;
    static int streak_len3 = 0;
    static int streak_len4 = 0;

    int ret12 = 0;
    int ret34 = 0;
    int code12 = 0;
    int code34 = 0;
    if(count[0]>pixnum*THRESHOLD_2)
    {
        code12 = 1;
        if(count[1]>pixnum*THRESHOLD_2&&count[2]>pixnum*THRESHOLD_2)
            code12 = 2;
        ret12 = calcOrientation(imgp, &box);
        if(ret12 == 1)
        {
            boxes1[streak_len1] = box;
            streak_len1++;
        }
    }
    else if(count[1]>pixnum*THRESHOLD_2)
    {
        code12 = 2;
        ret12 = calcOrientation(imgb, &box);
        if(ret12 == 1)
        {
            boxes2[streak_len2] = box;
            streak_len2++;
        }
    }
    else
    {
        code12 = 0;
        streak_len1 = 0;
        streak_len2 = 0;
    }

    if(count[3]>pixnum*THRESHOLD_2 || count[2]>pixnum*THRESHOLD_2)
    {
        int coff = 0.6;
        if(code12 == 1)
            coff = 0.3;
        if(count[3]>count[2]*coff)
        {
            code34 = 4;
            ret34 = calcOrientation(imgy, &box);
            if(ret34 == 1)
            {
                boxes4[streak_len4] = box;
                streak_len4++;
            }
        }
        else
        {
            code34 = 3;
            ret34 = calcOrientation(imgr, &box);
            if(ret34 == 1)
            {
                boxes3[streak_len3] = box;
                streak_len3++;
            }
        }
    }
    else
    {
        code34 = 0;
        streak_len3 = 0;
        streak_len4 = 0;
    }

    if(streak_len1 == 2)
    {
        DecodeAngle( boxes1[1],  boxes1[0], 1, angle, direction, width );
        streak_len1 = 0;
    }
    else if(streak_len2 == 2)
    {
        DecodeAngle( boxes2[1],  boxes2[0], 1, angle, direction, width );
        streak_len2 = 0;
    }
    if(streak_len3 == 2)
    {
        DecodeAngle( boxes3[1],  boxes3[0], 1, angle, direction, width );
        streak_len3 = 0;
    }
    else if(streak_len4 == 2)
    {
        DecodeAngle( boxes4[1],  boxes4[0], 1, angle, direction, width );
        streak_len4 = 0;
    }

    if(code12 != 0 && code34 == 0)
        code = code12;
    else if(code12 == 0 && code34 != 0)
        code = code34;
    else if(code12 != 0 && code34 != 0)
        code = code12*10 + code34;
    else
        code = 0;



#if	SHOWING_RESULT
    cvShowImage("image", img);
    cvShowImage("imagey", imgy);
    cvShowImage("imagep", imgp);
    cvShowImage("imager", imgr);
    cvShowImage("imageb", imgb);
    int key = cvWaitKey(0);
#endif

    cvReleaseImage(&imgr);
    cvReleaseImage(&imgb);
    cvReleaseImage(&imgy);
    cvReleaseImage(&imgp);
    cvReleaseImage(&imgv);
    //	cvReleaseImage(&imgs);
    cvReleaseImage(&hsv);
    //	cvDestroyAllWindows();

    return 0;

}




int correctAngle(int angle, int code, int direction)
{
    int fangle;
    /** angle  -> [-90, 90] **/
    /** fangle -> [0, 360]  **/

    if(code == 1 || code == 13 || code == 14 )
    {
        //		fangle = -1*angle;
        if(direction == -1)
        {
            if( angle>=0 )
                angle -= 180;
            else
                angle += 180;
        }

        fangle = -1*angle;

        if(fangle<0)
            fangle += 360;

        fangle -= 90;
        if(fangle<0)
            fangle += 360;

    }
    else if(code == 2 || code == 23 || code == 24)
    {
        // 		fangle = -1*angle;
        if(direction == 1)
        {
            if( angle>=0 )
                angle -= 180;
            else
                angle += 180;
        }

        fangle = -1*angle;

        if(fangle<0)
            fangle += 360;

        fangle -= 90;
        if(fangle<0)
            fangle += 360;

    }
    else if(code == 3)
    {
        //		fangle = -1*angle;
        if(direction == 1)
        {
            if( angle>=0 )
                angle -= 180;
            else
                angle += 180;
        }

        fangle = -1*angle;

        if(fangle<0)
            fangle += 360;

    }
    else if(code == 4)
    {
        //		fangle = -1*angle;
        if(direction == -1)
        {
            if( angle>=0 )
                angle -= 180;
            else
                angle += 180;
        }
        
        fangle = -1*angle;
        
        if(fangle<0)
            fangle += 360;
        
    }
    
    return fangle;
}

@implementation AUScanline
+ (int)TestEV:(IplImage *)img {
    int ret = 0;
    IplImage* img_hsv  = cvCreateImage(cvGetSize(img),8,3);
    cvCvtColor(img, img_hsv, CV_BGR2HSV);
    CvScalar hsv = cvAvg(img_hsv);
    //	double h = hsv.val[0];
    double s = hsv.val[1];
    double v = hsv.val[2];

    //	if(s<96)
    if(s<160.0)
    {
        if(v<50.0)
            ret = 1;
        else if(v>230.0)
            ret = -1;
        else
            ret = 0;
    }
    else
        ret = -2;
    
    cvReleaseImage(&img_hsv);
    
    return ret;
}

+ (int)GetCode:(IplImage *)img {
    int code = 0;
    float angle = 0;
    int direction = 0;

    int fangle = 0;
    int fcode = 0;
    classifyStreak(img, code, angle, direction);

    /** angle  -> [-90, 90] **/
    /** fangle -> [0, 360]  **/

    if(direction == 0)
        fangle = 0;
    else
        fangle = correctAngle( angle, code, direction);

    if(code > 10 )
        fcode = code*1000+fangle;
    else if(code > 0 )
        fcode = code*10000+fangle;
    
    return fcode;
}

+ (IplImage *)convertToIplImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height),
                                       IPL_DEPTH_8U, 4);
    CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData,
                                                    iplimage->width,
                                                    iplimage->height,
                                                    iplimage->depth,
                                                    iplimage->widthStep,
                                                    colorSpace,
                                                    kCGImageAlphaPremultipliedLast |
                                                    kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);

    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGB2BGR);
    cvReleaseImage(&iplimage);

    return ret;
}

+ (void)releaseImage:(IplImage *)img {
    cvReleaseImage(&img);
}
@end
