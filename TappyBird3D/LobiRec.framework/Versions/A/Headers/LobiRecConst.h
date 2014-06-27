//
//  LobiRecConst.h
//  LobiCore
//
//  Created by takahashi-kohei on 2014/06/06.
//  Copyright (c) 2014年 面白法人カヤック. All rights reserved.
//

#ifndef LobiCore_LobiRecConst_h
#define LobiCore_LobiRecConst_h


/**
 *  ゲーム録画中のワイプ表示
 */
typedef NS_ENUM(NSUInteger, KLVLiveWipeStatus) {
    /**
     *  ワイプなし
     */
    KLVWipeStatusNone = 0,
    /**
     *  インカメラワイプ
     */
    KLVWipeStatusInCamera,
    /**
     *  アイコン
     */
    KLVWipeStatusIcon,
};

/**
 *  ゲーム録画ファイルの保存領域が100MB以下になった際に録画処理が停止され、userInfoにnilを格納して通知する通知名称です。
 */
extern NSString *const KLVDryingUpInStorageNotification;

/**
 *  ゲーム録画情報をサーバにPOSTした際に、userInfoに"url"をキーとしたhttp://play.lobi.coのプレビューURLを格納して通知する通知名称です。
 */
extern NSString *const KLVMovieCreatedNotification;

/**
 *  ゲーム録画情報をサーバにPOST中エラーが発生した際に、userInfoにnilを格納して通知する通知名称です。
 */
extern NSString *const KLVMovieCreatedErrorNotification;

/**
 *  ゲーム録画ファイルをサーバにPOSTした際に、userInfoにnilを格納して通知する通知名称です。
 */
extern NSString *const KLVMovieUploadedNotification;

/**
 *  ゲーム録画ファイルをサーバにPOSTエラーが発生した際に、userInfoにnilを格納して通知する通知名称です。
 */
extern NSString *const KLVMovieUploadedErrorNotification;

/**
 *  動画ポストviewControllerを閉じた時に、userInfoに"tryPost"キー、BOOL値を値とした動画のポスト処理の有無を格納して通知する通知名称です。
 */
extern NSString *const KLVDismissingPostVideoViewControllerNotification;

/**
 *  mic録音をYESに設定した際にプライバシーにより設定できなかった場合に、userInfoにnilを格納して通知する通知名称です。
 */
extern NSString *const KLVMicEnableErrorNotification;


#endif
