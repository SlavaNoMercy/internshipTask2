trigger AccountInsertTrigger on Account (before insert) {
    System.debug('Inserting Account...');
}